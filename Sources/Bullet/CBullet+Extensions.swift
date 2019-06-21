//
//  CBullet+Extensions.swift
//  SwiftBullet
//
//  Created by Christian Treffs on 04.03.19.
//

// swiftlint:disable switch_case_on_newline

import CBullet

extension EnumSharedMemoryServerStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case CMD_ACTUAL_STATE_UPDATE_COMPLETED: return "CMD_ACTUAL_STATE_UPDATE_COMPLETED"
        case CMD_ACTUAL_STATE_UPDATE_FAILED: return "CMD_ACTUAL_STATE_UPDATE_FAILED"
        case CMD_ADD_USER_DATA_COMPLETED: return "CMD_ADD_USER_DATA_COMPLETED"
        case CMD_ADD_USER_DATA_FAILED: return "CMD_ADD_USER_DATA_FAILED"
        case CMD_BODY_INFO_COMPLETED: return "CMD_BODY_INFO_COMPLETED"
        case CMD_BODY_INFO_FAILED: return "CMD_BODY_INFO_FAILED"
        case CMD_BOX_COLLISION_SHAPE_CREATION_COMPLETED: return "CMD_BOX_COLLISION_SHAPE_CREATION_COMPLETED"
        case CMD_BULLET_DATA_STREAM_RECEIVED_COMPLETED: return "CMD_BULLET_DATA_STREAM_RECEIVED_COMPLETED"
        case CMD_BULLET_DATA_STREAM_RECEIVED_FAILED: return "CMD_BULLET_DATA_STREAM_RECEIVED_FAILED"
        case CMD_BULLET_LOADING_COMPLETED: return "CMD_BULLET_LOADING_COMPLETED"
        case CMD_BULLET_LOADING_FAILED: return "CMD_BULLET_LOADING_FAILED"
        case CMD_BULLET_SAVING_COMPLETED: return "CMD_BULLET_SAVING_COMPLETED"
        case CMD_BULLET_SAVING_FAILED: return "CMD_BULLET_SAVING_FAILED"
        case CMD_CALCULATE_INVERSE_KINEMATICS_COMPLETED: return "CMD_CALCULATE_INVERSE_KINEMATICS_COMPLETED"
        case CMD_CALCULATE_INVERSE_KINEMATICS_FAILED: return "CMD_CALCULATE_INVERSE_KINEMATICS_FAILED"
        case CMD_CALCULATED_INVERSE_DYNAMICS_COMPLETED: return "CMD_CALCULATED_INVERSE_DYNAMICS_COMPLETED"
        case CMD_CALCULATED_INVERSE_DYNAMICS_FAILED: return "CMD_CALCULATED_INVERSE_DYNAMICS_FAILED"
        case CMD_CALCULATED_JACOBIAN_COMPLETED: return "CMD_CALCULATED_JACOBIAN_COMPLETED"
        case CMD_CALCULATED_JACOBIAN_FAILED: return "CMD_CALCULATED_JACOBIAN_FAILED"
        case CMD_CALCULATED_MASS_MATRIX_COMPLETED: return "CMD_CALCULATED_MASS_MATRIX_COMPLETED"
        case CMD_CALCULATED_MASS_MATRIX_FAILED: return "CMD_CALCULATED_MASS_MATRIX_FAILED"
        case CMD_CAMERA_IMAGE_COMPLETED: return "CMD_CAMERA_IMAGE_COMPLETED"
        case CMD_CAMERA_IMAGE_FAILED: return "CMD_CAMERA_IMAGE_FAILED"
        case CMD_CHANGE_TEXTURE_COMMAND_FAILED: return "CMD_CHANGE_TEXTURE_COMMAND_FAILED"
        case CMD_CHANGE_USER_CONSTRAINT_COMPLETED: return "CMD_CHANGE_USER_CONSTRAINT_COMPLETED"
        case CMD_CHANGE_USER_CONSTRAINT_FAILED: return "CMD_CHANGE_USER_CONSTRAINT_FAILED"
        case CMD_CLIENT_COMMAND_COMPLETED: return "CMD_CLIENT_COMMAND_COMPLETED"
        case CMD_COLLISION_SHAPE_INFO_COMPLETED: return "CMD_COLLISION_SHAPE_INFO_COMPLETED"
        case CMD_COLLISION_SHAPE_INFO_FAILED: return "CMD_COLLISION_SHAPE_INFO_FAILED"
        case CMD_CONTACT_POINT_INFORMATION_COMPLETED: return "CMD_CONTACT_POINT_INFORMATION_COMPLETED"
        case CMD_CONTACT_POINT_INFORMATION_FAILED: return "CMD_CONTACT_POINT_INFORMATION_FAILED"
        case CMD_CREATE_COLLISION_SHAPE_COMPLETED: return "CMD_CREATE_COLLISION_SHAPE_COMPLETED"
        case CMD_CREATE_COLLISION_SHAPE_FAILED: return "CMD_CREATE_COLLISION_SHAPE_FAILED"
        case CMD_CREATE_MULTI_BODY_COMPLETED: return "CMD_CREATE_MULTI_BODY_COMPLETED"
        case CMD_CREATE_MULTI_BODY_FAILED: return "CMD_CREATE_MULTI_BODY_FAILED"
        case CMD_CREATE_VISUAL_SHAPE_COMPLETED: return "CMD_CREATE_VISUAL_SHAPE_COMPLETED"
        case CMD_CREATE_VISUAL_SHAPE_FAILED: return "CMD_CREATE_VISUAL_SHAPE_FAILED"
        case CMD_CUSTOM_COMMAND_COMPLETED: return "CMD_CUSTOM_COMMAND_COMPLETED"
        case CMD_CUSTOM_COMMAND_FAILED: return "CMD_CUSTOM_COMMAND_FAILED"
        case CMD_DEBUG_LINES_COMPLETED: return "CMD_DEBUG_LINES_COMPLETED"
        case CMD_DEBUG_LINES_OVERFLOW_FAILED: return "CMD_DEBUG_LINES_OVERFLOW_FAILED"
        case CMD_DESIRED_STATE_RECEIVED_COMPLETED: return "CMD_DESIRED_STATE_RECEIVED_COMPLETED"
        case CMD_GET_DYNAMICS_INFO_COMPLETED: return "CMD_GET_DYNAMICS_INFO_COMPLETED"
        case CMD_GET_DYNAMICS_INFO_FAILED: return "CMD_GET_DYNAMICS_INFO_FAILED"
        case CMD_INVALID_STATUS: return "CMD_INVALID_STATUS"
        case CMD_LOAD_SOFT_BODY_COMPLETED: return "CMD_LOAD_SOFT_BODY_COMPLETED"
        case CMD_LOAD_SOFT_BODY_FAILED: return "CMD_LOAD_SOFT_BODY_FAILED"
        case CMD_LOAD_TEXTURE_COMPLETED: return "CMD_LOAD_TEXTURE_COMPLETED"
        case CMD_LOAD_TEXTURE_FAILED: return "CMD_LOAD_TEXTURE_FAILED"
        case CMD_MAX_SERVER_COMMANDS: return "CMD_MAX_SERVER_COMMANDS"
        case CMD_MJCF_LOADING_COMPLETED: return "CMD_MJCF_LOADING_COMPLETED"
        case CMD_MJCF_LOADING_FAILED: return "CMD_MJCF_LOADING_FAILED"
        case CMD_REMOVE_BODY_COMPLETED: return "CMD_REMOVE_BODY_COMPLETED"
        case CMD_REMOVE_BODY_FAILED: return "CMD_REMOVE_BODY_FAILED"
        case CMD_REMOVE_USER_CONSTRAINT_COMPLETED: return "CMD_REMOVE_USER_CONSTRAINT_COMPLETED"
        case CMD_REMOVE_USER_CONSTRAINT_FAILED: return "CMD_REMOVE_USER_CONSTRAINT_FAILED"
        case CMD_REMOVE_USER_DATA_COMPLETED: return "CMD_REMOVE_USER_DATA_COMPLETED"
        case CMD_REMOVE_USER_DATA_FAILED: return "CMD_REMOVE_USER_DATA_FAILED"
        case CMD_REQUEST_AABB_OVERLAP_COMPLETED: return "CMD_REQUEST_AABB_OVERLAP_COMPLETED"
        case CMD_REQUEST_AABB_OVERLAP_FAILED: return "CMD_REQUEST_AABB_OVERLAP_FAILED"
        case CMD_REQUEST_COLLISION_INFO_COMPLETED: return "CMD_REQUEST_COLLISION_INFO_COMPLETED"
        case CMD_REQUEST_COLLISION_INFO_FAILED: return "CMD_REQUEST_COLLISION_INFO_FAILED"
        case CMD_REQUEST_INTERNAL_DATA_COMPLETED: return "CMD_REQUEST_INTERNAL_DATA_COMPLETED"
        case CMD_REQUEST_INTERNAL_DATA_FAILED: return "CMD_REQUEST_INTERNAL_DATA_FAILED"
        case CMD_REQUEST_KEYBOARD_EVENTS_DATA_COMPLETED: return "CMD_REQUEST_KEYBOARD_EVENTS_DATA_COMPLETED"
        case CMD_REQUEST_KEYBOARD_EVENTS_DATA_FAILED: return "CMD_REQUEST_KEYBOARD_EVENTS_DATA_FAILED"
        case CMD_REQUEST_MOUSE_EVENTS_DATA_COMPLETED: return "CMD_REQUEST_MOUSE_EVENTS_DATA_COMPLETED"
        case CMD_REQUEST_OPENGL_VISUALIZER_CAMERA_COMPLETED: return "CMD_REQUEST_OPENGL_VISUALIZER_CAMERA_COMPLETED"
        case CMD_REQUEST_OPENGL_VISUALIZER_CAMERA_FAILED: return "CMD_REQUEST_OPENGL_VISUALIZER_CAMERA_FAILED"
        case CMD_REQUEST_PHYSICS_SIMULATION_PARAMETERS_COMPLETED: return "CMD_REQUEST_PHYSICS_SIMULATION_PARAMETERS_COMPLETED"
        case CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED: return "CMD_REQUEST_RAY_CAST_INTERSECTIONS_COMPLETED"
        case CMD_REQUEST_USER_DATA_COMPLETED: return "CMD_REQUEST_USER_DATA_COMPLETED"
        case CMD_REQUEST_USER_DATA_FAILED: return "CMD_REQUEST_USER_DATA_FAILED"
        case CMD_REQUEST_VR_EVENTS_DATA_COMPLETED: return "CMD_REQUEST_VR_EVENTS_DATA_COMPLETED"
        case CMD_RESET_SIMULATION_COMPLETED: return "CMD_RESET_SIMULATION_COMPLETED"
        case CMD_RESTORE_STATE_COMPLETED: return "CMD_RESTORE_STATE_COMPLETED"
        case CMD_RESTORE_STATE_FAILED: return "CMD_RESTORE_STATE_FAILED"
        case CMD_RIGID_BODY_CREATION_COMPLETED: return "CMD_RIGID_BODY_CREATION_COMPLETED"
        case CMD_SAVE_STATE_COMPLETED: return "CMD_SAVE_STATE_COMPLETED"
        case CMD_SAVE_STATE_FAILED: return "CMD_SAVE_STATE_FAILED"
        case CMD_SAVE_WORLD_COMPLETED: return "CMD_SAVE_WORLD_COMPLETED"
        case CMD_SAVE_WORLD_FAILED: return "CMD_SAVE_WORLD_FAILED"
        case CMD_SDF_LOADING_COMPLETED: return "CMD_SDF_LOADING_COMPLETED"
        case CMD_SDF_LOADING_FAILED: return "CMD_SDF_LOADING_FAILED"
        case CMD_SET_JOINT_FEEDBACK_COMPLETED: return "CMD_SET_JOINT_FEEDBACK_COMPLETED"
        case CMD_SHARED_MEMORY_NOT_INITIALIZED: return "CMD_SHARED_MEMORY_NOT_INITIALIZED"
        case CMD_STATE_LOGGING_COMPLETED: return "CMD_STATE_LOGGING_COMPLETED"
        case CMD_STATE_LOGGING_FAILED: return "CMD_STATE_LOGGING_FAILED"
        case CMD_STATE_LOGGING_START_COMPLETED: return "CMD_STATE_LOGGING_START_COMPLETED"
        case CMD_STEP_FORWARD_SIMULATION_COMPLETED: return "CMD_STEP_FORWARD_SIMULATION_COMPLETED"
        case CMD_SYNC_BODY_INFO_COMPLETED: return "CMD_SYNC_BODY_INFO_COMPLETED"
        case CMD_SYNC_BODY_INFO_FAILED: return "CMD_SYNC_BODY_INFO_FAILED"
        case CMD_SYNC_USER_DATA_COMPLETED: return "CMD_SYNC_USER_DATA_COMPLETED"
        case CMD_SYNC_USER_DATA_FAILED: return "CMD_SYNC_USER_DATA_FAILED"
        case CMD_UNKNOWN_COMMAND_FLUSHED: return "CMD_UNKNOWN_COMMAND_FLUSHED"
        case CMD_URDF_LOADING_COMPLETED: return "CMD_URDF_LOADING_COMPLETED"
        case CMD_URDF_LOADING_FAILED: return "CMD_URDF_LOADING_FAILED"
        case CMD_USER_CONSTRAINT_COMPLETED: return "CMD_USER_CONSTRAINT_COMPLETED"
        case CMD_USER_CONSTRAINT_FAILED: return "CMD_USER_CONSTRAINT_FAILED"
        case CMD_USER_CONSTRAINT_INFO_COMPLETED: return "CMD_USER_CONSTRAINT_INFO_COMPLETED"
        case CMD_USER_CONSTRAINT_REQUEST_STATE_COMPLETED: return "CMD_USER_CONSTRAINT_REQUEST_STATE_COMPLETED"
        case CMD_USER_DEBUG_DRAW_COMPLETED: return "CMD_USER_DEBUG_DRAW_COMPLETED"
        case CMD_USER_DEBUG_DRAW_FAILED: return "CMD_USER_DEBUG_DRAW_FAILED"
        case CMD_USER_DEBUG_DRAW_PARAMETER_COMPLETED: return "CMD_USER_DEBUG_DRAW_PARAMETER_COMPLETED"
        case CMD_VISUAL_SHAPE_INFO_COMPLETED: return "CMD_VISUAL_SHAPE_INFO_COMPLETED"
        case CMD_VISUAL_SHAPE_INFO_FAILED: return "CMD_VISUAL_SHAPE_INFO_FAILED"
        case CMD_VISUAL_SHAPE_UPDATE_COMPLETED: return "CMD_VISUAL_SHAPE_UPDATE_COMPLETED"
        case CMD_VISUAL_SHAPE_UPDATE_FAILED: return "CMD_VISUAL_SHAPE_UPDATE_FAILED"
        case CMD_WAITING_FOR_CLIENT_COMMAND: return "CMD_WAITING_FOR_CLIENT_COMMAND"
        default: return "__UNKNWOWN__COMMAND__"
        }
    }
}
