-- Migration: base_tables
-- Database: PostgreSQL
-- Description: 全ビジネステーブル（organization_id付き）

-- ============================================================================
-- TABLE: files
-- ============================================================================
CREATE TABLE public.files (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    filename TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT DEFAULT ''::TEXT,
    type TEXT NOT NULL,
    blob TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_files_organization_id ON public.files(organization_id);

-- ============================================================================
-- TABLE: flickr_photo
-- ============================================================================
CREATE TABLE public.flickr_photo (
    id TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    secret TEXT NOT NULL,
    server TEXT NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX idx_flickr_photo_organization_id ON public.flickr_photo(organization_id);

-- ============================================================================
-- CAMERA FILES TABLES
-- ============================================================================
CREATE TABLE public.cam_file_exe_stage (
    stage INTEGER NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    name TEXT NOT NULL,
    PRIMARY KEY (stage, organization_id)
);

CREATE INDEX idx_cam_file_exe_stage_organization_id ON public.cam_file_exe_stage(organization_id);

CREATE TABLE public.cam_file_exe (
    name TEXT NOT NULL,
    cam TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    stage INTEGER NOT NULL,
    PRIMARY KEY (name, cam, organization_id)
);

CREATE INDEX idx_cam_file_exe_organization_id ON public.cam_file_exe(organization_id);

CREATE TABLE public.cam_files (
    name TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    date TEXT NOT NULL,
    hour TEXT NOT NULL,
    type TEXT NOT NULL,
    cam TEXT NOT NULL,
    flickr_id TEXT,
    PRIMARY KEY (name, organization_id)
);

CREATE INDEX idx_cam_files_organization_id ON public.cam_files(organization_id);
CREATE INDEX idx_cam_files_date ON public.cam_files(date);

-- ============================================================================
-- CAR INSPECTION TABLES
-- ============================================================================
CREATE TABLE public.car_inspection (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    "CertInfoImportFileVersion" TEXT NOT NULL,
    "Acceptoutputno" TEXT NOT NULL,
    "FormType" TEXT NOT NULL,
    "ElectCertMgNo" TEXT NOT NULL,
    "CarId" TEXT NOT NULL,
    "ElectCertPublishdateE" TEXT NOT NULL,
    "ElectCertPublishdateY" TEXT NOT NULL,
    "ElectCertPublishdateM" TEXT NOT NULL,
    "ElectCertPublishdateD" TEXT NOT NULL,
    "GrantdateE" TEXT NOT NULL,
    "GrantdateY" TEXT NOT NULL,
    "GrantdateM" TEXT NOT NULL,
    "GrantdateD" TEXT NOT NULL,
    "TranspotationBureauchiefName" TEXT NOT NULL,
    "EntryNoCarNo" TEXT NOT NULL,
    "ReggrantdateE" TEXT NOT NULL,
    "ReggrantdateY" TEXT NOT NULL,
    "ReggrantdateM" TEXT NOT NULL,
    "ReggrantdateD" TEXT NOT NULL,
    "FirstregistdateE" TEXT NOT NULL,
    "FirstregistdateY" TEXT NOT NULL,
    "FirstregistdateM" TEXT NOT NULL,
    "CarName" TEXT NOT NULL,
    "CarNameCode" TEXT NOT NULL,
    "CarNo" TEXT NOT NULL,
    "Model" TEXT NOT NULL,
    "EngineModel" TEXT NOT NULL,
    "OwnernameLowLevelChar" TEXT NOT NULL,
    "OwnernameHighLevelChar" TEXT NOT NULL,
    "OwnerAddressChar" TEXT NOT NULL,
    "OwnerAddressNumValue" TEXT NOT NULL,
    "OwnerAddressCode" TEXT NOT NULL,
    "UsernameLowLevelChar" TEXT NOT NULL,
    "UsernameHighLevelChar" TEXT NOT NULL,
    "UserAddressChar" TEXT NOT NULL,
    "UserAddressNumValue" TEXT NOT NULL,
    "UserAddressCode" TEXT NOT NULL,
    "UseheadqrterChar" TEXT NOT NULL,
    "UseheadqrterNumValue" TEXT NOT NULL,
    "UseheadqrterCode" TEXT NOT NULL,
    "CarKind" TEXT NOT NULL,
    "Use" TEXT NOT NULL,
    "PrivateBusiness" TEXT NOT NULL,
    "CarShape" TEXT NOT NULL,
    "CarShapeCode" TEXT NOT NULL,
    "NoteCap" TEXT NOT NULL,
    "Cap" TEXT NOT NULL,
    "NoteMaxloadage" TEXT NOT NULL,
    "Maxloadage" TEXT NOT NULL,
    "NoteCarWgt" TEXT NOT NULL,
    "CarWgt" TEXT NOT NULL,
    "NoteCarTotalWgt" TEXT NOT NULL,
    "CarTotalWgt" TEXT NOT NULL,
    "NoteLength" TEXT NOT NULL,
    "Length" TEXT NOT NULL,
    "NoteWidth" TEXT NOT NULL,
    "Width" TEXT NOT NULL,
    "NoteHeight" TEXT NOT NULL,
    "Height" TEXT NOT NULL,
    "FfAxWgt" TEXT NOT NULL,
    "FrAxWgt" TEXT NOT NULL,
    "RfAxWgt" TEXT NOT NULL,
    "RrAxWgt" TEXT NOT NULL,
    "Displacement" TEXT NOT NULL,
    "FuelClass" TEXT NOT NULL,
    "ModelSpecifyNo" TEXT NOT NULL,
    "ClassifyAroundNo" TEXT NOT NULL,
    "ValidPeriodExpirdateE" TEXT NOT NULL,
    "ValidPeriodExpirdateY" TEXT NOT NULL,
    "ValidPeriodExpirdateM" TEXT NOT NULL,
    "ValidPeriodExpirdateD" TEXT NOT NULL,
    "NoteInfo" TEXT NOT NULL,
    "TwodimensionCodeInfoEntryNoCarNo" TEXT NOT NULL,
    "TwodimensionCodeInfoCarNo" TEXT NOT NULL,
    "TwodimensionCodeInfoValidPeriodExpirdate" TEXT NOT NULL,
    "TwodimensionCodeInfoModel" TEXT NOT NULL,
    "TwodimensionCodeInfoModelSpecifyNoClassifyAroundNo" TEXT NOT NULL,
    "TwodimensionCodeInfoCharInfo" TEXT NOT NULL,
    "TwodimensionCodeInfoEngineModel" TEXT NOT NULL,
    "TwodimensionCodeInfoCarNoStampPlace" TEXT NOT NULL,
    "TwodimensionCodeInfoFirstregistdate" TEXT NOT NULL,
    "TwodimensionCodeInfoFfAxWgt" TEXT NOT NULL,
    "TwodimensionCodeInfoFrAxWgt" TEXT NOT NULL,
    "TwodimensionCodeInfoRfAxWgt" TEXT NOT NULL,
    "TwodimensionCodeInfoRrAxWgt" TEXT NOT NULL,
    "TwodimensionCodeInfoNoiseReg" TEXT NOT NULL,
    "TwodimensionCodeInfoNearNoiseReg" TEXT NOT NULL,
    "TwodimensionCodeInfoDriveMethod" TEXT NOT NULL,
    "TwodimensionCodeInfoOpacimeterMeasCar" TEXT NOT NULL,
    "TwodimensionCodeInfoNoxPmMeasMode" TEXT NOT NULL,
    "TwodimensionCodeInfoNoxValue" TEXT NOT NULL,
    "TwodimensionCodeInfoPmValue" TEXT NOT NULL,
    "TwodimensionCodeInfoSafeStdDate" TEXT NOT NULL,
    "TwodimensionCodeInfoFuelClassCode" TEXT NOT NULL,
    "RegistCarLightCar" TEXT NOT NULL,
    created TEXT NOT NULL,
    "Modified" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "ElectCertMgNo", "ElectCertPublishdateE", "ElectCertPublishdateY", "ElectCertPublishdateM", "ElectCertPublishdateD")
);

CREATE INDEX idx_car_inspection_organization_id ON public.car_inspection(organization_id);
CREATE INDEX idx_car_inspection_car_id ON public.car_inspection("CarId");

CREATE TABLE public.car_inspection_files (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    type TEXT NOT NULL,
    "ElectCertMgNo" TEXT NOT NULL,
    "ElectCertPublishdateE" TEXT NOT NULL,
    "ElectCertPublishdateY" TEXT NOT NULL,
    "ElectCertPublishdateM" TEXT NOT NULL,
    "ElectCertPublishdateD" TEXT NOT NULL,
    created TEXT NOT NULL,
    modified TEXT DEFAULT ''::TEXT,
    deleted TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_car_inspection_files_organization_id ON public.car_inspection_files(organization_id);
CREATE INDEX idx_car_inspection_files_elect_cert ON public.car_inspection_files("ElectCertMgNo");

CREATE TABLE public.car_inspection_files_a (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    type TEXT NOT NULL,
    "ElectCertMgNo" TEXT NOT NULL,
    "GrantdateE" TEXT NOT NULL,
    "GrantdateY" TEXT NOT NULL,
    "GrantdateM" TEXT NOT NULL,
    "GrantdateD" TEXT NOT NULL,
    created TEXT NOT NULL,
    modified TEXT DEFAULT ''::TEXT,
    deleted TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_car_inspection_files_a_organization_id ON public.car_inspection_files_a(organization_id);

CREATE TABLE public.car_inspection_files_b (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    type TEXT NOT NULL,
    "ElectCertMgNo" TEXT NOT NULL,
    "GrantdateE" TEXT NOT NULL,
    "GrantdateY" TEXT NOT NULL,
    "GrantdateM" TEXT NOT NULL,
    "GrantdateD" TEXT NOT NULL,
    created TEXT NOT NULL,
    modified TEXT DEFAULT ''::TEXT,
    deleted TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_car_inspection_files_b_organization_id ON public.car_inspection_files_b(organization_id);

CREATE TABLE public.car_inspection_deregistration (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    "CarId" TEXT NOT NULL,
    "TwodimensionCodeInfoCarNo" TEXT NOT NULL,
    "CarNo" TEXT NOT NULL,
    "ValidPeriodExpirdateE" TEXT NOT NULL,
    "ValidPeriodExpirdateY" TEXT NOT NULL,
    "ValidPeriodExpirdateM" TEXT NOT NULL,
    "ValidPeriodExpirdateD" TEXT NOT NULL,
    "TwodimensionCodeInfoValidPeriodExpirdate" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "CarId", "TwodimensionCodeInfoValidPeriodExpirdate")
);

CREATE INDEX idx_car_inspection_deregistration_organization_id ON public.car_inspection_deregistration(organization_id);

CREATE TABLE public.car_inspection_deregistration_files (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    "CarId" TEXT NOT NULL,
    "TwodimensionCodeInfoValidPeriodExpirdate" TEXT NOT NULL,
    "fileUuid" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "CarId", "TwodimensionCodeInfoValidPeriodExpirdate", "fileUuid")
);

CREATE INDEX idx_car_inspection_deregistration_files_organization_id ON public.car_inspection_deregistration_files(organization_id);

CREATE TABLE public.car_ins_sheet_ichiban_cars (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    id_cars TEXT,
    "ElectCertMgNo" TEXT NOT NULL,
    "ElectCertPublishdateE" TEXT NOT NULL,
    "ElectCertPublishdateY" TEXT NOT NULL,
    "ElectCertPublishdateM" TEXT NOT NULL,
    "ElectCertPublishdateD" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "ElectCertMgNo", "ElectCertPublishdateE", "ElectCertPublishdateY", "ElectCertPublishdateM", "ElectCertPublishdateD")
);

CREATE INDEX idx_car_ins_sheet_ichiban_cars_organization_id ON public.car_ins_sheet_ichiban_cars(organization_id);

CREATE TABLE public.car_ins_sheet_ichiban_cars_a (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    id_cars TEXT,
    "ElectCertMgNo" TEXT NOT NULL,
    "GrantdateE" TEXT NOT NULL,
    "GrantdateY" TEXT NOT NULL,
    "GrantdateM" TEXT NOT NULL,
    "GrantdateD" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "ElectCertMgNo", "GrantdateE", "GrantdateY", "GrantdateM", "GrantdateD")
);

CREATE INDEX idx_car_ins_sheet_ichiban_cars_a_organization_id ON public.car_ins_sheet_ichiban_cars_a(organization_id);

-- ============================================================================
-- CAR REGISTRY TABLES
-- ============================================================================
CREATE TABLE public.ichiban_cars (
    id TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    id4 TEXT NOT NULL,
    name TEXT,
    "name_R" TEXT,
    shashu TEXT NOT NULL,
    sekisai NUMERIC,
    reg_date TEXT,
    parch_date TEXT,
    scrap_date TEXT,
    bumon_code_id TEXT,
    driver_id TEXT,
    PRIMARY KEY (id, organization_id)
);

CREATE INDEX idx_ichiban_cars_organization_id ON public.ichiban_cars(organization_id);
CREATE INDEX idx_ichiban_cars_id4 ON public.ichiban_cars(id4);

CREATE TABLE public.dtako_cars_ichiban_cars (
    id_dtako TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    id TEXT,
    PRIMARY KEY (id_dtako, organization_id)
);

CREATE INDEX idx_dtako_cars_ichiban_cars_organization_id ON public.dtako_cars_ichiban_cars(organization_id);

-- ============================================================================
-- KUDGURI TABLES (Vehicle Tracking System)
-- ============================================================================
CREATE TABLE public.kudguri (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "unkouNo" TEXT NOT NULL,
    "kudguriUuid" TEXT NOT NULL,
    "readDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "targetDriverCd" TEXT,
    "targetDriverName" TEXT,
    "startDatetime" TEXT,
    "endDatetime" TEXT,
    "eventCd" TEXT,
    "eventName" TEXT,
    "startMileage" TEXT,
    "endMileage" TEXT,
    "sectionTime" TEXT,
    "sectionDistance" TEXT,
    "startCityCd" TEXT,
    "startCityName" TEXT,
    "endCityCd" TEXT,
    "endCityName" TEXT,
    "startPlaceCd" TEXT,
    "startPlaceName" TEXT,
    "endPlaceCd" TEXT,
    "endPlaceName" TEXT,
    "startGpsValid" TEXT,
    "startGpsLat" TEXT,
    "startGpsLng" TEXT,
    "endGpsValid" TEXT,
    "endGpsLat" TEXT,
    "endGpsLng" TEXT,
    "overLimitMax" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudguri_organization_id ON public.kudguri(organization_id);

CREATE TABLE public.kudgcst (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "kudguriUuid" TEXT,
    "unkouNo" TEXT,
    "unkouDate" TEXT,
    "readDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "startDatetime" TEXT,
    "endDatetime" TEXT,
    "ferryCompanyCd" TEXT,
    "ferryCompanyName" TEXT,
    "boardingPlaceCd" TEXT,
    "boardingPlaceName" TEXT,
    "tripNumber" TEXT,
    "dropoffPlaceCd" TEXT,
    "dropoffPlaceName" TEXT,
    "settlementType" TEXT,
    "settlementTypeName" TEXT,
    "standardFare" TEXT,
    "contractFare" TEXT,
    "ferryVehicleType" TEXT,
    "ferryVehicleTypeName" TEXT,
    "assumedDistance" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudgcst_organization_id ON public.kudgcst(organization_id);
CREATE INDEX idx_kudgcst_kudguri_uuid ON public.kudgcst("kudguriUuid");

CREATE TABLE public.kudgfry (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "kudguriUuid" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "unkouNo" TEXT,
    "unkouDate" TEXT,
    "readDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "driverCd2" TEXT,
    "driverName2" TEXT,
    "relevantDatetime" TEXT,
    "refuelInspectCategory" TEXT,
    "refuelInspectCategoryName" TEXT,
    "refuelInspectType" TEXT,
    "refuelInspectTypeName" TEXT,
    "refuelInspectKind" TEXT,
    "refuelInspectKindName" TEXT,
    "refillAmount" TEXT,
    "ownOtherType" TEXT,
    mileage TEXT,
    "meterValue" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudgfry_organization_id ON public.kudgfry(organization_id);
CREATE INDEX idx_kudgfry_kudguri_uuid ON public.kudgfry("kudguriUuid");

CREATE TABLE public.kudgful (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "kudguriUuid" TEXT,
    "unkouNo" TEXT,
    "readDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "targetDriverCd" TEXT,
    "targetDriverName" TEXT,
    "startDatetime" TEXT,
    "endDatetime" TEXT,
    "eventCd" TEXT,
    "eventName" TEXT,
    "startMileage" TEXT,
    "endMileage" TEXT,
    "sectionTime" TEXT,
    "sectionDistance" TEXT,
    "startCityCd" TEXT,
    "startCityName" TEXT,
    "endCityCd" TEXT,
    "endCityName" TEXT,
    "startPlaceCd" TEXT,
    "startPlaceName" TEXT,
    "endPlaceCd" TEXT,
    "endPlaceName" TEXT,
    "startGpsValid" TEXT,
    "startGpsLat" TEXT,
    "startGpsLng" TEXT,
    "endGpsValid" TEXT,
    "endGpsLat" TEXT,
    "endGpsLng" TEXT,
    "overLimitMax" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudgful_organization_id ON public.kudgful(organization_id);
CREATE INDEX idx_kudgful_kudguri_uuid ON public.kudgful("kudguriUuid");

CREATE TABLE public.kudgivt (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "kudguriUuid" TEXT,
    "unkouNo" TEXT,
    "readDate" TEXT,
    "unkouDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "targetDriverCd" TEXT,
    "targetDriverName" TEXT,
    "clockInDatetime" TEXT,
    "clockOutDatetime" TEXT,
    "departureDatetime" TEXT,
    "returnDatetime" TEXT,
    "departureMeter" TEXT,
    "returnMeter" TEXT,
    "totalMileage" TEXT,
    "destinationCityName" TEXT,
    "destinationPlaceName" TEXT,
    "actualMileage" TEXT,
    "localDriveTime" TEXT,
    "expressDriveTime" TEXT,
    "bypassDriveTime" TEXT,
    "actualDriveTime" TEXT,
    "emptyDriveTime" TEXT,
    "work1Time" TEXT,
    "work2Time" TEXT,
    "work3Time" TEXT,
    "work4Time" TEXT,
    "work5Time" TEXT,
    "work6Time" TEXT,
    "work7Time" TEXT,
    "work8Time" TEXT,
    "work9Time" TEXT,
    "work10Time" TEXT,
    "state1Distance" TEXT,
    "state1Time" TEXT,
    "state2Distance" TEXT,
    "state2Time" TEXT,
    "state3Distance" TEXT,
    "state3Time" TEXT,
    "state4Distance" TEXT,
    "state4Time" TEXT,
    "state5Distance" TEXT,
    "state5Time" TEXT,
    "ownMainFuel" TEXT,
    "ownMainAdditive" TEXT,
    "ownConsumable" TEXT,
    "otherMainFuel" TEXT,
    "otherMainAdditive" TEXT,
    "otherConsumable" TEXT,
    "localSpeedOverMax" TEXT,
    "localSpeedOverTime" TEXT,
    "localSpeedOverCount" TEXT,
    "expressSpeedOverMax" TEXT,
    "expressSpeedOverTime" TEXT,
    "expressSpeedOverCount" TEXT,
    "dedicatedSpeedOverMax" TEXT,
    "dedicatedSpeedOverTime" TEXT,
    "dedicatedSpeedOverCount" TEXT,
    "idlingTime" TEXT,
    "idlingTimeCount" TEXT,
    "rotationOverMax" TEXT,
    "rotationOverCount" TEXT,
    "rotationOverTime" TEXT,
    "rapidAccelCount1" TEXT,
    "rapidAccelCount2" TEXT,
    "rapidAccelCount3" TEXT,
    "rapidAccelCount4" TEXT,
    "rapidAccelCount5" TEXT,
    "rapidAccelMax" TEXT,
    "rapidAccelMaxSpeed" TEXT,
    "rapidDecelCount1" TEXT,
    "rapidDecelCount2" TEXT,
    "rapidDecelCount3" TEXT,
    "rapidDecelCount4" TEXT,
    "rapidDecelCount5" TEXT,
    "rapidDecelMax" TEXT,
    "rapidDecelMaxSpeed" TEXT,
    "rapidCurveCount1" TEXT,
    "rapidCurveCount2" TEXT,
    "rapidCurveCount3" TEXT,
    "rapidCurveCount4" TEXT,
    "rapidCurveCount5" TEXT,
    "rapidCurveMax" TEXT,
    "rapidCurveMaxSpeed" TEXT,
    "continuousDriveOverCount" TEXT,
    "continuousDriveMaxTime" TEXT,
    "continuousDriveTotalTime" TEXT,
    "waveDriveCount" TEXT,
    "waveDriveMaxTime" TEXT,
    "waveDriveMaxSpeedDiff" TEXT,
    "localSpeedScore" TEXT,
    "expressSpeedScore" TEXT,
    "dedicatedSpeedScore" TEXT,
    "localDistanceScore" TEXT,
    "expressDistanceScore" TEXT,
    "dedicatedDistanceScore" TEXT,
    "rapidAccelScore" TEXT,
    "rapidDecelScore" TEXT,
    "rapidCurveScore" TEXT,
    "actualLowSpeedRotationScore" TEXT,
    "actualHighSpeedRotationScore" TEXT,
    "emptyLowSpeedRotationScore" TEXT,
    "emptyHighSpeedRotationScore" TEXT,
    "idlingScore" TEXT,
    "continuousDriveScore" TEXT,
    "waveDriveScore" TEXT,
    "safetyScore" TEXT,
    "economyScore" TEXT,
    "totalScore" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudgivt_organization_id ON public.kudgivt(organization_id);
CREATE INDEX idx_kudgivt_kudguri_uuid ON public.kudgivt("kudguriUuid");

CREATE TABLE public.kudgsir (
    uuid TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    hash TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT,
    "kudguriUuid" TEXT,
    "unkouNo" TEXT,
    "readDate" TEXT,
    "officeCd" TEXT,
    "officeName" TEXT,
    "vehicleCd" TEXT,
    "vehicleName" TEXT,
    "driverCd1" TEXT,
    "driverName1" TEXT,
    "targetDriverType" TEXT NOT NULL,
    "targetDriverCd" TEXT,
    "targetDriverName" TEXT,
    "startDatetime" TEXT,
    "endDatetime" TEXT,
    "eventCd" TEXT,
    "eventName" TEXT,
    "startMileage" TEXT,
    "endMileage" TEXT,
    "sectionTime" TEXT,
    "sectionDistance" TEXT,
    "startCityCd" TEXT,
    "startCityName" TEXT,
    "endCityCd" TEXT,
    "endCityName" TEXT,
    "startPlaceCd" TEXT,
    "startPlaceName" TEXT,
    "endPlaceCd" TEXT,
    "endPlaceName" TEXT,
    "startGpsValid" TEXT,
    "startGpsLat" TEXT,
    "startGpsLng" TEXT,
    "endGpsValid" TEXT,
    "endGpsLat" TEXT,
    "endGpsLng" TEXT,
    "overLimitMax" TEXT,
    PRIMARY KEY (uuid)
);

CREATE INDEX idx_kudgsir_organization_id ON public.kudgsir(organization_id);
CREATE INDEX idx_kudgsir_kudguri_uuid ON public.kudgsir("kudguriUuid");

-- ============================================================================
-- SALES TABLES
-- ============================================================================
CREATE TABLE public.uriage (
    name TEXT NOT NULL,
    bumon TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    kingaku INTEGER,
    type INTEGER,
    cam INTEGER,
    date TEXT NOT NULL,
    PRIMARY KEY (name, bumon, date, organization_id)
);

CREATE INDEX idx_uriage_organization_id ON public.uriage(organization_id);
CREATE INDEX idx_uriage_date ON public.uriage(date);

CREATE TABLE public.uriage_jisha (
    bumon TEXT NOT NULL,
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    kingaku INTEGER,
    type INTEGER,
    date TEXT NOT NULL,
    PRIMARY KEY (bumon, date, organization_id)
);

CREATE INDEX idx_uriage_jisha_organization_id ON public.uriage_jisha(organization_id);

-- ============================================================================
-- DTAKOLOGS TABLE (デジタコログ)
-- ============================================================================
CREATE TABLE public.dtakologs (
    organization_id UUID NOT NULL REFERENCES public.organizations(id),
    __type TEXT NOT NULL,
    "AddressDispC" TEXT,
    "AddressDispP" TEXT,
    "AllState" TEXT,
    "AllStateEx" TEXT,
    "AllStateFontColor" TEXT,
    "AllStateFontColorIndex" INTEGER NOT NULL,
    "AllStateRyoutColor" TEXT NOT NULL,
    "BranchCD" INTEGER NOT NULL,
    "BranchName" TEXT NOT NULL,
    "ComuDateTime" TEXT,
    "CurrentWorkCD" INTEGER NOT NULL,
    "CurrentWorkName" TEXT,
    "DataDateTime" TEXT DEFAULT '20/1/1 00:00',
    "DataFilterType" INTEGER NOT NULL,
    "DispFlag" INTEGER NOT NULL,
    "DriverCD" INTEGER NOT NULL,
    "DriverName" TEXT,
    "EventVal" TEXT,
    "GPSDirection" INTEGER NOT NULL,
    "GPSEnable" INTEGER NOT NULL,
    "GPSLatiAndLong" TEXT,
    "GPSLatitude" INTEGER NOT NULL,
    "GPSLongitude" INTEGER NOT NULL,
    "GPSSatelliteNum" INTEGER NOT NULL,
    "ODOMeter" TEXT,
    "OperationState" INTEGER NOT NULL,
    "ReciveEventType" INTEGER NOT NULL,
    "RecivePacketType" INTEGER NOT NULL,
    "ReciveTypeColorName" TEXT,
    "ReciveTypeName" TEXT,
    "ReciveWorkCD" INTEGER NOT NULL,
    "Revo" INTEGER NOT NULL,
    "SettingTemp" TEXT NOT NULL,
    "SettingTemp1" TEXT NOT NULL,
    "SettingTemp3" TEXT NOT NULL,
    "SettingTemp4" TEXT NOT NULL,
    "Speed" REAL NOT NULL,
    "StartWorkDateTime" TEXT,
    "State" TEXT,
    "State1" TEXT,
    "State2" TEXT,
    "State3" TEXT,
    "StateFlag" TEXT NOT NULL,
    "SubDriverCD" INTEGER NOT NULL,
    "Temp1" TEXT,
    "Temp2" TEXT,
    "Temp3" TEXT,
    "Temp4" TEXT,
    "TempState" INTEGER NOT NULL,
    "VehicleCD" INTEGER NOT NULL,
    "VehicleIconColor" TEXT,
    "VehicleIconLabelForDatetime" TEXT,
    "VehicleIconLabelForDriver" TEXT,
    "VehicleIconLabelForVehicle" TEXT,
    "VehicleName" TEXT NOT NULL,
    PRIMARY KEY (organization_id, "DataDateTime", "VehicleCD")
);

CREATE INDEX idx_dtakologs_organization_id ON public.dtakologs(organization_id);
CREATE INDEX idx_dtakologs_vehicle_cd ON public.dtakologs("VehicleCD");
CREATE INDEX idx_dtakologs_driver_cd ON public.dtakologs("DriverCD");
CREATE INDEX idx_dtakologs_branch_cd ON public.dtakologs("BranchCD");

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS (kudguri関連)
-- ============================================================================
ALTER TABLE public.kudgcst
    ADD CONSTRAINT fk_kudgcst_kudguri
    FOREIGN KEY ("kudguriUuid") REFERENCES public.kudguri(uuid);

ALTER TABLE public.kudgfry
    ADD CONSTRAINT fk_kudgfry_kudguri
    FOREIGN KEY ("kudguriUuid") REFERENCES public.kudguri(uuid);

ALTER TABLE public.kudgful
    ADD CONSTRAINT fk_kudgful_kudguri
    FOREIGN KEY ("kudguriUuid") REFERENCES public.kudguri(uuid);

ALTER TABLE public.kudgivt
    ADD CONSTRAINT fk_kudgivt_kudguri
    FOREIGN KEY ("kudguriUuid") REFERENCES public.kudguri(uuid);

ALTER TABLE public.kudgsir
    ADD CONSTRAINT fk_kudgsir_kudguri
    FOREIGN KEY ("kudguriUuid") REFERENCES public.kudguri(uuid);

ALTER TABLE public.car_inspection_deregistration_files
    ADD CONSTRAINT fk_car_inspection_deregistration_files_files
    FOREIGN KEY ("fileUuid") REFERENCES public.files(uuid);
