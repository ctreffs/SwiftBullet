//
//  PhysicsCommand.swift
//
//
//  Created by Christian Treffs on 10.02.20.
//

import CBullet

public protocol PhysicsCommand {
    func makeCommand(_ build: PhysicsCommandBuilder) -> PhysicsCommandBuilder.Executable
    func execute(on client: b3PhysicsClientHandle) throws
}

extension PhysicsCommand {
    public func execute(on client: b3PhysicsClientHandle) throws {
        let cmd = makeCommand(PhysicsCommandBuilder(client))
        try cmd.execute()
    }
}

public struct PhysicsCommandBuilder {
    enum Error: Swift.Error {
        case sharedMemoryHandleNil
        case commandFailedWithStatusCode(Int32)
        case executionFailedWithStatus(EnumSharedMemoryServerStatus)
    }

    let client: b3PhysicsClientHandle

    init(_ client: b3PhysicsClientHandle) {
        self.client = client
    }

    func command(_ closure: (b3PhysicsClientHandle) -> b3SharedMemoryCommandHandle?) -> Intermediate {
        guard let handle: b3SharedMemoryCommandHandle = closure(client) else {
            // TODO: fail with function parameters
            return Intermediate(client, .failure(Error.sharedMemoryHandleNil))
        }
        return Intermediate(client, .success(handle))
    }

    public struct Intermediate {
        let client: b3PhysicsClientHandle
        let cmd: Result<b3SharedMemoryCommandHandle, Swift.Error>

        init(_ client: b3PhysicsClientHandle, _ previousCommand: Result<b3SharedMemoryCommandHandle, Swift.Error>) {
            self.client = client
            self.cmd = previousCommand
        }

        func set(_ closure: (b3SharedMemoryCommandHandle) -> Int32) -> Intermediate {
            switch cmd {
            case let .success(handle):
                let status = closure(handle)

                switch status {
                case 0:
                    return Intermediate(client, .success(handle))

                default:
                    return Intermediate(client, .failure(Error.commandFailedWithStatusCode(status)))
                }

            case let .failure(error):
                return Intermediate(client, .failure(error))
            }
        }

        func expect(_ status: EnumSharedMemoryServerStatus) -> Executable {
            Executable(client, cmd, status)
        }
    }

    public struct Executable {
        let client: b3PhysicsClientHandle
        let cmd: Result<b3SharedMemoryCommandHandle, Swift.Error>
        let expectedStatus: EnumSharedMemoryServerStatus

        init(_ client: b3PhysicsClientHandle, _ cmd: Result<b3SharedMemoryCommandHandle, Swift.Error>, _ expectedStatus: EnumSharedMemoryServerStatus) {
            self.client = client
            self.cmd = cmd
            self.expectedStatus = expectedStatus
        }

        func execute() throws {
            switch cmd {
            case let .failure(error):
                throw error

            case let .success(cmdHandle):
                try executeCmdAndWait(cmdHandle)
            }
        }

        func executeCmdAndWait(_ cmdHandle: b3SharedMemoryCommandHandle) throws {
            let statusHandle: b3SharedMemoryStatusHandle = b3SubmitClientCommandAndWaitStatus(client, cmdHandle)
            let status = EnumSharedMemoryServerStatus(rawValue: UInt32(b3GetStatusType(statusHandle)))
            guard status == expectedStatus else {
                throw Error.executionFailedWithStatus(status)
            }
        }
    }
}
