//
//  PhysicsCommand.swift
//
//
//  Created by Christian Treffs on 10.02.20.
//

import CBullet

public typealias MemoryCommandHandleResult = Result<b3SharedMemoryCommandHandle, Swift.Error>
public typealias MemoryStatusHandleResult = Result<b3SharedMemoryStatusHandle, Swift.Error>
public typealias SettableClosure = (PhysicsCommandBuilder.Settable) -> PhysicsCommandBuilder.Settable
public typealias SettableIndexedClosure = (PhysicsCommandBuilder.Settable, Int) -> PhysicsCommandBuilder.Settable
public typealias SettableBodyIndexClosure = (PhysicsCommandBuilder.Settable, _ bodyId: Int32, _ linkId: Int32) -> PhysicsCommandBuilder.Settable

public struct PhysicsCommandBuilder {
    enum Error: Swift.Error {
        case sharedMemoryHandleNil
        case commandFailedWithStatusCode(Int32, String, Int)
        case executionFailedWithStatus(EnumSharedMemoryServerStatus)
        case canNotSubmitCommand
        case idBelowZero(Int32)
    }

    let client: b3PhysicsClientHandle

    init(_ client: b3PhysicsClientHandle) {
        self.client = client
    }

    func command(_ closure: (b3PhysicsClientHandle) -> b3SharedMemoryCommandHandle?) -> Settable {
        guard let handle: b3SharedMemoryCommandHandle = closure(client) else {
            return Settable(client, .failure(Error.sharedMemoryHandleNil))
        }
        return Settable(client, .success(handle))
    }

    public struct Settable {
        let client: b3PhysicsClientHandle
        let cmd: MemoryCommandHandleResult

        init(_ client: b3PhysicsClientHandle, _ previousCommand: MemoryCommandHandleResult) {
            self.client = client
            self.cmd = previousCommand
        }

        func set(_ function: String = #function, _ line: Int = #line, _ closure: (b3SharedMemoryCommandHandle) -> Int32) -> Settable {
            switch cmd {
            case let .success(handle):
                let status = closure(handle)

                switch status {
                case 0:
                    return Settable(client, .success(handle))

                default:
                    return Settable(client, .failure(Error.commandFailedWithStatusCode(status, function, line)))
                }

            case let .failure(error):
                return Settable(client, .failure(error))
            }
        }

        func injectOne(_ closure: (Settable) -> Settable) -> Settable {
            closure(self)
        }

        func inject(_ closures: [SettableClosure]) -> Settable {
            closures.reduce(self) { prev, next in
                next(prev)
            }
        }

        func injectWith(bodyIndex: Int32, linkIndex: Int32, _ closures: [SettableBodyIndexClosure]) -> Settable {
            closures.reduce(self) { prev, next in
                next(prev, bodyIndex, linkIndex)
            }
        }

        func injectIndexed(_ closures: [SettableIndexedClosure]) -> Settable {
            closures.enumerated().reduce(self) { prev, next in
                next.element(prev, next.offset)
            }
        }

        func apply(_ function: String = #function, _ line: Int = #line, _ closure: (b3SharedMemoryCommandHandle) -> Void) -> Settable {
            switch cmd {
            case let .success(handle):
                closure(handle)
                return Settable(client, .success(handle))

            case let .failure(error):
                return Settable(client, .failure(error))
            }
        }

        func expect(_ status: EnumSharedMemoryServerStatus) -> Executable {
            Executable(client, cmd, status)
        }
    }

    public struct Executable {
        let client: b3PhysicsClientHandle
        let cmd: MemoryCommandHandleResult
        let expectedStatus: EnumSharedMemoryServerStatus

        init(_ client: b3PhysicsClientHandle, _ cmd: MemoryCommandHandleResult, _ expectedStatus: EnumSharedMemoryServerStatus) {
            self.client = client
            self.cmd = cmd
            self.expectedStatus = expectedStatus
        }

        @discardableResult
        func submit() -> MemoryStatusHandleResult {
            switch cmd {
            case let .failure(error):
                return .failure(error)

            case let .success(cmdHandle):
                return submitAndWaitStatus(cmdHandle)
            }
        }

        private func submitAndWaitStatus(_ cmdHandle: b3SharedMemoryCommandHandle) -> MemoryStatusHandleResult {
            let statusHandle: b3SharedMemoryStatusHandle = b3SubmitClientCommandAndWaitStatus(client, cmdHandle)
            let status = EnumSharedMemoryServerStatus(rawValue: UInt32(b3GetStatusType(statusHandle)))
            guard status == expectedStatus else {
                return .failure(Error.executionFailedWithStatus(status))
            }

            return .success(statusHandle)
        }
    }
}

extension MemoryStatusHandleResult {
    func command(_ function: String = #function, _ line: Int = #line, expectedStatus: Int32 = 0, _ closure: (b3SharedMemoryStatusHandle) -> Int32) -> MemoryStatusHandleResult {
        switch self {
        case let .success(statusHandle):
            let status = closure(statusHandle)

            switch status {
            case expectedStatus:
                return .success(statusHandle)

            default:
                return .failure(PhysicsCommandBuilder.Error.commandFailedWithStatusCode(status, function, line))
            }

        case let .failure(error):
            return .failure(error)
        }
    }

    func id(_ function: String = #function, _ line: Int = #line, _ closure: (b3SharedMemoryStatusHandle) -> Int32) -> Int32 {
        switch self {
        case let .success(statusHandle):
            let id = closure(statusHandle)

            guard id >= 0 else {
                assertionFailure("Id below zero")
                return -1
            }

            return id

        case let .failure(error):
            assertionFailure("\(error)")
            return -1
        }
    }
}
