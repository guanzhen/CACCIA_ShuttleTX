/*
    FileName: Ptkl_shuttle.h
    Version: 1
    Description: First Version: Interface to shuttle extension TX machine.
    Author: Igor Zimmermann
    Date: 2016-04-15

    Version: 2
    Description: Added: Interface Version
    Author: Igor Zimmermann
    Date: 2016-04-21

    Version: 3
    Description: Removed: PAR_VERSION
    Author: Igor Zimmermann
    Date: 2016-04-22

    Version: 4
    Description: Added: failed board options
    Author: Igor Zimmermann
    Date: 2016-05-04

    Version: 5
    Description: Changed: Lane/Shuttle Parameters
    Author: Igor Zimmermann
    Date: 2016-05-11

    Version: 5
    Description: Changed: Shuttle Parameters, Added CMD_INSERT_PCB, Added CMD_GET_REF_STATUS
    Author: Igor Zimmermann
    Date: 2016-06-22

    Version: 6
    Description: Changed: Added CMD_GET_INTERFACE_STATUS
    Author: Igor Zimmermann
    Date: 2016-07-08

    Version: 7
    Description: Changed: Coding of Lane, Added: Coding of Section
    Author: Andreas Loy
    Date: 2016-07-13

    Version: 8
    Description: Changed: IO definition changed, Added CMD_COVER_BLOCK, CMD_PREPARE_CALIBRATE_SENSOR
    Author: Igor Zimmermann
    Date: 2016-08-03

    Version: 9
    Description: Added: INP_SAFETY_CIRCUIT_INTERRUPTED
    Author: Igor Zimmermann
    Date: 2016-08-31

    Version: 10
    Description: Added: PCB_STATE_ERROR
    Author: Igor Zimmermann
    Date: 2016-09-08

    Version: 11
    Description: Removed: ACK_PCB_MOVING_IN, ACK_PCB_MOVING_OUT, ACK_NO_PCB_PRESENT, ACK_PCB_PRESENT; Added: ERR_PCB_MOVING_IN, ERR_PCB_MOVING_OUT, ERR_NO_PCB_PRESENT, ERR_PCB_PRESENT
    Author: Igor Zimmermann
    Date: 2016-09-12

    Version: 12
    Description: Added: ERR_CAL_PCB_SENSOR, ERR_CRASH_SENSOR
    Author: Igor Zimmermann
    Date: 2016-09-14

    Version: 13
    Description: Added: P_SHUTTLE_POSITION_R, Renamed: P_SHUTTLE_POSITION to P_SHUTTLE_POSITION_L
    Author: Igor Zimmermann
    Date: 2016-09-19

    Version: 14
    Description: Added: PAR_SENSOR_CALIB_NUMBER, PAR_RIGHT_MECH_LIMIT, PAR_LEFT_MECH_LIMIT, PAR_MAX_ABS_WIDTH
    Author: Igor Zimmermann
    Date: 2016-09-23

    Version: 15
    Description: Added: PAR_ENDUR_LIMIT_ADJ
    Author: Igor Zimmermann
    Date: 2017-01-09

    Version: 16
    Description: Added: PUB_MSG_BARCODE, OPT_HW_EXTENDED_BELTS, OPT_HW_BARCODE_TRIGGER
    Author: Igor Zimmermann
    Date: 2017-01-20

    Version: 17
    Description: Added: PCB_DATA_OPTIONS_SINGLE, Changed OUTPUTS for BARCODE
    Author: Igor Zimmermann
    Date: 2017-02-08

*/
    //Interface
        #define    MAJOR_VERSION_ISS_SHUTTLE                       0x0000
        #define    MINOR_VERSION_ISS_SHUTTLE                       0x0003

    //************************************************************************
    //*              CAN commands                                            *
    //************************************************************************
        #define    CMD_SET_PCB_DATA                                0x20
        #define    CMD_GET_PCB_DATA                                0x21
        #define    CMD_SET_LANE_PAR                                0x22
        #define    CMD_GET_LANE_PAR                                0x23
        #define    CMD_GET_SHUTTLE_PAR                             0x24
        #define    CMD_CHECK_LANE_POS                              0x25
        #define    CMD_GET_BARCODE_LABEL                           0x26
        #define    CMD_GET_PCB_STATE                               0x27
        #define    CMD_DELETE_PCB                                  0x28
        #define    CMD_INSERT_PCB                                  0x29
        #define    CMD_SET_HW_OPTION                               0x30
        #define    CMD_GET_HW_OPTION                               0x31
        #define    CMD_SET_PARAM                                   0x32
        #define    CMD_GET_PARAM                                   0x33
        #define    CMD_INFO                                        0x34
        #define    CMD_SET_WIDTH_OFFSET                            0x35
        #define    CMD_SET_FIXED_RAIL_OFFSET                       0x36
        #define    CMD_GET_IO_STATE                                0x37
        #define    CMD_SET_OUTPUT                                  0x38
        #define    CMD_MOTOR_GET_POSITION                          0x39
        #define    CMD_MOTOR_NOTIFY_POS                            0x3A
        #define    CMD_GET_REF_STATUS                              0x3B
        #define    CMD_GET_INTERFACE_STATUS                        0x3C
        #define    CMD_COVER_BLOCK                                 0x3D
        #define    CMD_RESET_FIXED_RAIL_OFFSET                     0x3E
        #define    CMD_PREPARE_REFERENCE                           0x41
        #define    CMD_PREPARE_MOVE_IN                             0x42
        #define    CMD_PREPARE_MOVE_OUT                            0x43
        #define    CMD_PREPARE_MOVE_SHUTTLE                        0x44
        #define    CMD_PREPARE_WIDTH_ADJUSTMENT                    0x45
        #define    CMD_PREPARE_SHUTTLE_POSITION                    0x46
        #define    CMD_PREPARE_BARCODE_SCANNER                     0x47
        #define    CMD_PREPARE_MOTOR_REFERENCE                     0x48
        #define    CMD_PREPARE_MOTOR_CALIBRATE                     0x49
        #define    CMD_PREPARE_MOTOR_CURRENT                       0x4A
        #define    CMD_PREPARE_MOTOR_VELOCITY                      0x4B
        #define    CMD_PREPARE_MOTOR_POSITION                      0x4C
        #define    CMD_PREPARE_ENDURANCE_RUN                       0x4D
        #define    CMD_PREPARE_CALIBRATE_SENSOR                    0x4E

    //************************************************************************
    //*              Private acknowledge messages                            *
    //************************************************************************
        #define    ACK_OK                                          0x00
        #define    ACK_NOK                                         0x01
        #define    ACK_UNKNOWN_CMD                                 0x02
        #define    ACK_SYNTAX_ERR                                  0x0F
        #define    ACK_PARAM_UNDEF                                 0x22
        #define    ACK_PARAM_VALUE_FALSE                           0x23
        #define    ACK_BUSY                                        0x26
        #define    ACK_OFFSET_FIXED_RAIL                           0x27
        #define    ACK_WIDTH_OFFSET_RANGE                          0x28
        #define    ACK_PCB_ID_FALSE                                0x29
        #define    ACK_PUB_ERROR                                   0x7F

    //************************************************************************
    //*              Public error messages                                   *
    //************************************************************************
        #define    ERR_CONTROL_VOLTAGE                             0x02
        #define    ERR_EMERGENCY_STOP                              0x03
        #define    ERR_ABORTED                                     0x04
        #define    ERR_MOVE_IN                                     0x10
        #define    ERR_MOVE_OUT                                    0x11
        #define    ERR_POSITION_RAIL                               0x12
        #define    ERR_LANE_WIDTH                                  0x13
        #define    ERR_OFFSET_WIDTH                                0x14
        #define    ERR_SHUTTLE_BLOCKED                             0x15
        #define    ERR_WIDTH_ADJ_BLOCKED                           0x16
        #define    ERR_WA_NOT_REFERENCED                           0x17
        #define    ERR_SHUTTLE_NOT_REFERENCED                      0x18
        #define    ERR_DELIVERY_UPSTREAM                           0x19
        #define    ERR_ARRIVED_DOWNSTREAM                          0x1A
        #define    ERR_TRAVEL_RANGE_SHUTTLE                        0x1B
        #define    ERR_TRAVEL_RANGE_WA                             0x1C
        #define    ERR_TRAVEL_RANGE_RAIL_R                         0x1D
        #define    ERR_TRAVEL_RANGE_RAIL_L                         0x1E
        #define    ERR_MECH_LIMIT_RIGHT_SIDE                       0x1F
        #define    ERR_MECH_LIMIT_LEFT_SIDE                        0x20
        #define    ERR_PCB_MOVING_IN                               0x24
        #define    ERR_PCB_MOVING_OUT                              0x25
        #define    ERR_NO_PCB_PRESENT                              0x2A
        #define    ERR_PCB_PRESENT                                 0x2B
        #define    ERR_MOTOR_MOVING                                0x30
        #define    ERR_MOTOR_COUNT                                 0x31
        #define    ERR_MOTOR_INDEX_PULSE                           0x32
        #define    ERR_MOTOR_ENCODER                               0x33
        #define    ERR_MOTOR_REFERENCE_MOVED                       0x34
        #define    ERR_BARCODE_TIMEOUT                             0x40
        #define    ERR_BARCODE_SYNTAX                              0x41
        #define    ERR_BARCODE_FEEDBACK                            0x42
        #define    ERR_CAL_PCB_SENSOR                              0x50
        #define    ERR_CRASH_SENSOR                                0x51
        #define    ERR_ESW_SHUTTLE                                 0x80

    //************************************************************************
    //*              Command parameter                                       *
    //************************************************************************
    
    //Parameter CMD_INIT
        #define    PARAM_INIT_RESET                                0x00
        #define    PARAM_INIT_DATA                                 0x02
        #define    PARAM_INIT_IDLE                                 0x04

    //Parameter CMD_GET_PCB_STATE
        #define    PARAM_PCB_STATE_START                           0x10
        #define    PARAM_PCB_STATE_NEXT                            0x11

    //Coding of hw options
        #define    OPT_HW_BARCODE                                  0x00
        #define    OPT_HW_BARCODE_L1T                              0x01
        #define    OPT_HW_BARCODE_L1B                              0x02
        #define    OPT_HW_BARCODE_L2T                              0x03
        #define    OPT_HW_BARCODE_L2B                              0x04
        #define    OPT_HW_UP_FAILED_BOARD                          0x05
        #define    OPT_HW_DOWN_FAILED_BOARD                        0x06
        #define    OPT_HW_BARCODE_TRIGGER                          0x07
        #define    OPT_HW_EXTENDED_BELTS                           0x08

    //Parameter of CMD_PCB_DATA
        #define    PCB_DATA_LENGTH                                 0x00
        #define    PCB_POS_BARCODE                                 0x01
        #define    PCB_DATA_OPTIONS                                0x02
        #define    PCB_DATA_OPTIONS_SINGLE                         0x03

    //Coding of pcb status
        #define    PCB_STATE_DELETED                               0x00
        #define    PCB_STATE_INSERTED                              0x01
        #define    PCB_STATE_REMOVED                               0x02
        #define    PCB_STATE_MOVING                                0x03
        #define    PCB_STATE_MOVED                                 0x04
        #define    PCB_STATE_MOVING_SHUTTLE                        0x05
        #define    PCB_STATE_MOVED_SHUTTLE                         0x06
        #define    PCB_STATE_ERROR                                 0x07

    //Parameter of CMD_PCB_BARCODE, Barcode label side
        #define    OPT_USE_BARCODE_TOP                             0x01
        #define    OPT_USE_BARCODE_BOTTOM                          0x02
        #define    OPT_FAILED_BOARD                                0x03
        #define    OPT_PCB_INSERTED                                0x04

    //Parameter of PCB_REFERENCE, A simple reference is done with the following defines for a PCB data reference
        #define    PCB_REF_SHUTTLE                                 0x00
        #define    PCB_REF_UPSTREAM_LANE1                          0x01
        #define    PCB_REF_UPSTREAM_LANE2                          0x02

    //Parameter CMD_INFO
        #define    PARAM_NAME_PAR_START                            0x00
        #define    PARAM_NAME_PAR_NEXT                             0x01

    //Parameter CMD_GET_BARCODE_LABEL
        #define    PARAM_BARCODE_START                             0x20
        #define    PARAM_BARCODE_NEXT                              0x21

    //Shuttle parameter 
    // Parameter CMD_SET_PARAM and CMD_GET_PARAM
        #define    PAR_CHANGED                                     0x02
        #define    PAR_CONTROL_BOARD_ID                            0x03
        #define    PAR_VELOCITY_DRIVE_IN                           0x0B
        #define    PAR_VELOCITY_DRIVE_OUT                          0x0C
        #define    PAR_CONV_ACCELERATION                           0x0D
        #define    PAR_TIMEOUT_MOVE_OUT                            0x10
        #define    PAR_TIMEOUT_MOVE_IN                             0x11
        #define    PAR_TIMEOUT_BARCODE                             0x12
        #define    PAR_MIN_WIDTH                                   0x13
        #define    PAR_WA_VELOCITY                                 0x14
        #define    PAR_SHUTTLE_VELOCITY                            0x15
        #define    PAR_SHUTTLE_ACCELERATION                        0x16
        #define    PAR_SHUTTLE_JERK                                0x17
        #define    PAR_CURRENT_SHUTTLE_MOTOR                       0x18
        #define    PAR_CURRENT_WA_MOTOR                            0x19
        #define    PAR_VELOCITY_TEST_CONV_MOTOR                    0x1A
        #define    PAR_VELOCITY_TEST_SHUTTLE_MOTOR                 0x1B
        #define    PAR_VELOCITY_TEST_WA_MOTOR                      0x1C
        #define    PAR_TRAVEL_RANGE_SHUTTLE                        0x1D
        #define    PAR_TRAVEL_RANGE_WA                             0x1E
        #define    PAR_ENDUR_LIMIT_ADJ                             0x1F
        #define    PAR_SHUTTLE_CURRENT_FORW                        0x31
        #define    PAR_SHUTTLE_CURRENT_BACKW                       0x32
        #define    PAR_WA_CURRENT_FORW                             0x33
        #define    PAR_WA_CURRENT_BACKW                            0x34
        #define    PAR_CONV_CURRENT_FORW                           0x35
        #define    PAR_CONV_CURRENT_BACKW                          0x36
        #define    PAR_RIGHT_MECH_LIMIT                            0x37
        #define    PAR_LEFT_MECH_LIMIT                             0x38
        #define    PAR_MAX_ABS_WIDTH                               0x39
        #define    PAR_OPERATING_HOURS                             0x40
        #define    PAR_BOARD_THROUGHPUT                            0x41
        #define    PAR_SHUTTLE_MOTOR_MILEAGE                       0x42
        #define    PAR_WA_MOTOR_MILEAGE                            0x43
        #define    PAR_CONV_MOTOR_MILEAGE                          0x44
        #define    PAR_SENSOR_CALIB_NUMBER                         0x45
        #define    PAR_LAST                                        0xFFF
        #define    PAR_NEXT                                        0xFFF

    //Parameter CMD_GET_SHUTTLE_PAR
        #define    P_SHUTTLE_WIDTH                                 0x01
        #define    P_SHUTTLE_MIN_WIDTH                             0x02
        #define    P_SHUTTLE_MAX_WIDTH                             0x03
        #define    P_SHUTTLE_OFFSET_WIDTH                          0x04
        #define    P_SHUTTLE_POSITION_L                            0x05
        #define    P_SHUTTLE_MIN_POS_L                             0x06
        #define    P_SHUTTLE_MAX_POS_L                             0x07
        #define    P_SHUTTLE_MIN_POS_R                             0x08
        #define    P_SHUTTLE_MAX_POS_R                             0x09
        #define    P_SHUTTLE_POSITION_R                            0x0A

    //Parameter CMD_GET_LANE_PAR and CMD_SET_LANE_PAR
        #define    P_LANE_FIXED_RAIL                               0x01
        #define    P_LANE_POS_FIXED_RAIL                           0x02
        #define    P_LANE_WIDTH                                    0x03
        #define    P_LANE_OFFSET_FIXED_RAIL                        0x04
        #define    P_LANE_R_MIN_POS                                0x10
        #define    P_LANE_R_MAX_POS                                0x11
        #define    P_LANE_L_MIN_POS                                0x12
        #define    P_LANE_L_MAX_POS                                0x13
        #define    P_LANE_MAX_WIDTH                                0x14

    //************************************************************************
    //*              Public message type                                     *
    //************************************************************************
        #define    PUB_MSG_ERR_PARAM                               0x01
        #define    PUB_MSG_IO_STATE                                0x13
        #define    PUB_MSG_MACHINE_INTERFACE                       0x14
        #define    PUB_MSG_PCB_STATE                               0x22
        #define    PUB_MSG_BARCODE                                 0x23
        #define    PUB_MSG_CONV_MOTOR_POSITION                     0x81
        #define    PUB_MSG_SHUTTLE_MOTOR_POSITION                  0x82
        #define    PUB_MSG_WA_MOTOR_POSITION                       0x83
        #define    PUB_MSG_ENDURANCE_RUN                           0x90

    //************************************************************************
    //*              Coding of lane                                          *
    //************************************************************************
        #define    LANE_UNDEFINED                                  0x00
        #define    LANE_UPSTREAM_1                                 0x01
        #define    LANE_UPSTREAM_2                                 0x02
        #define    LANE_DOWNSTREAM_1                               0x03
        #define    LANE_DOWNSTREAM_2                               0x04

    //************************************************************************
    //*              Coding of section                                          *
    //************************************************************************
        #define    SECTION_UPSTREAM                                0x00
        #define    SECTION_SHUTTLE                                 0x01
        #define    SECTION_DOWNSTREAM                              0x02

    //************************************************************************
    //*              Coding of lane check                                    *
    //************************************************************************
        #define    LANE_CONF_OK                                    0x00
        #define    LANE_CONF_RIGHT_RAIL_FALSE                      0x01
        #define    LANE_CONF_LEFT_RAIL_FALSE                       0x02

    //************************************************************************
    //*              Coding of get ref status                                *
    //************************************************************************
        #define    STATUS_OK                                       0x00
        #define    STATUS_NOT_REF                                  0x01

    //************************************************************************
    //*              Coding of motor                                         *
    //************************************************************************
        #define    MOTOR_1                                         0x01
        #define    MOTOR_SHUTTLE                                   0x02
        #define    MOTOR_WIDTH_ADJ                                 0x03
        #define    MOTOR_CONVEYOR                                  0x04
        #define    MOTOR_5                                         0x05

    //************************************************************************
    //*              Coding of motor movement mode                           *
    //************************************************************************
        #define    MOTOR_POSITION_RELATIVE                         0x00
        #define    MOTOR_POSITION_ABSOLUTE                         0x01

    //************************************************************************
    //*              Inputs / outputs                                        *
    //************************************************************************
        #define    INP_START                                       0x01
        #define    INP_HALT                                        0x02
        #define    INP_EMERGENCY_STOP                              0x03
        #define    INP_COVER                                       0x04
        #define    INP_CONTROL_VOLTAGE_40                          0x05
        #define    INP_SAFETY_CIRCUIT_INTERRUPTED                  0x06
        #define    INP_PCB_SENSOR                                  0x08
        #define    INP_PCB_JAM_INPUT                               0x09
        #define    INP_PCB_JAM_OUTPUT                              0x0A
        #define    INP_BARCODE_SCANNER_PRESENT                     0x0B
        #define    INP_SMEMA_U1_PCB_AVAILABLE                      0x10
        #define    INP_SMEMA_U1_FAILED_BOARD                       0x11
        #define    INP_SMEMA_U2_PCB_AVAILABLE                      0x12
        #define    INP_SMEMA_U2_FAILED_BOARD                       0x13
        #define    INP_SMEMA_D1_MACHINE_READY                      0x14
        #define    INP_SMEMA_D2_MACHINE_READY                      0x15
        #define    OUTP_BRAKE_WA_MOTOR                             0x19
        #define    OUTP_BRAKE_SHUTTLE_MOTOR                        0x1A
        #define    OUTP_ACTIVATE_BARCODE_1                         0x1B
        #define    OUTP_ACTIVATE_BARCODE_2                         0x1C
        #define    OUTP_COVER_LOCK_1                               0x1D
        #define    OUTP_COVER_LOCK_2                               0x1E
        #define    OUTP_SMEMA_U1_MACHINE_READY                     0x20
        #define    OUTP_SMEMA_U2_MACHINE_READY                     0x21
        #define    OUTP_SMEMA_D1_PCB_AVAILABLE                     0x22
        #define    OUTP_SMEMA_D1_FAILED_BOARD                      0x23
        #define    OUTP_SMEMA_D2_PCB_AVAILABLE                     0x24
        #define    OUTP_SMEMA_D2_FAILED_BOARD                      0x25
        #define    OUTP_ACTIVATE_BARCODE_3                         0x26
        #define    OUTP_ACTIVATE_BARCODE_4                         0x27

    //************************************************************************
    //*              Coding of barcode position (bit)                        *
    //************************************************************************
        #define    BARCODE_POSITION_UNDEF                          0x00
        #define    BARCODE_POSITION_TOP                            0x01
        #define    BARCODE_POSITION_BOTTOM                         0x02

