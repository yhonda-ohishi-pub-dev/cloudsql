-- Migration: full_schema
-- Database: PostgreSQL
-- Description: Full database schema from db202512051200 dump

-- ============================================================================
-- SCHEMAS
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS drizzle;
CREATE SCHEMA IF NOT EXISTS my_schema;

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================
CREATE TYPE my_schema.colors AS ENUM ('red', 'green', 'blue');

-- ============================================================================
-- TABLE: drizzle.__drizzle_migrations (Drizzle ORM migrations tracking)
-- ============================================================================
CREATE TABLE IF NOT EXISTS drizzle.__drizzle_migrations (
    id INTEGER NOT NULL,
    hash TEXT NOT NULL,
    created_at BIGINT,
    PRIMARY KEY (id)
);

-- ============================================================================
-- TABLE: my_schema.users
-- ============================================================================
CREATE TABLE IF NOT EXISTS my_schema.users (
    id INTEGER NOT NULL,
    name TEXT,
    color my_schema.colors DEFAULT 'red'::my_schema.colors,
    PRIMARY KEY (id)
);

-- ============================================================================
-- TABLE: public.users
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.users (
    id INTEGER
);

-- ============================================================================
-- TABLE: public.files
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.files (
    uuid TEXT NOT NULL,
    filename TEXT NOT NULL,
    created TEXT NOT NULL,
    deleted TEXT DEFAULT ''::TEXT,
    type TEXT NOT NULL,
    blob TEXT,
    PRIMARY KEY (uuid)
);

-- ============================================================================
-- TABLE: public.flickr_photo
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.flickr_photo (
    id TEXT NOT NULL,
    secret TEXT NOT NULL,
    server TEXT NOT NULL,
    PRIMARY KEY (id)
);

-- ============================================================================
-- CAMERA FILES TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.cam_file_exe_stage (
    stage INTEGER NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (stage)
);

CREATE TABLE IF NOT EXISTS public.cam_file_exe (
    name TEXT NOT NULL,
    cam TEXT NOT NULL,
    stage INTEGER NOT NULL,
    PRIMARY KEY (name, cam)
);

CREATE TABLE IF NOT EXISTS public.cam_files (
    name TEXT NOT NULL,
    date TEXT NOT NULL,
    hour TEXT NOT NULL,
    type TEXT NOT NULL,
    cam TEXT NOT NULL,
    flickr_id TEXT,
    PRIMARY KEY (name)
);

-- ============================================================================
-- CAR INSPECTION TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.car_inspection (
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
    PRIMARY KEY ("ElectCertMgNo", "ElectCertPublishdateE", "ElectCertPublishdateY", "ElectCertPublishdateM", "ElectCertPublishdateD")
);

CREATE TABLE IF NOT EXISTS public.car_inspection_files (
    uuid TEXT NOT NULL,
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

CREATE TABLE IF NOT EXISTS public.car_inspection_files_a (
    uuid TEXT NOT NULL,
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

CREATE TABLE IF NOT EXISTS public.car_inspection_files_b (
    uuid TEXT NOT NULL,
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

CREATE TABLE IF NOT EXISTS public.car_inspection_deregistration (
    "CarId" TEXT NOT NULL,
    "TwodimensionCodeInfoCarNo" TEXT NOT NULL,
    "CarNo" TEXT NOT NULL,
    "ValidPeriodExpirdateE" TEXT NOT NULL,
    "ValidPeriodExpirdateY" TEXT NOT NULL,
    "ValidPeriodExpirdateM" TEXT NOT NULL,
    "ValidPeriodExpirdateD" TEXT NOT NULL,
    "TwodimensionCodeInfoValidPeriodExpirdate" TEXT NOT NULL,
    PRIMARY KEY ("CarId", "TwodimensionCodeInfoValidPeriodExpirdate")
);

CREATE TABLE IF NOT EXISTS public.car_inspection_deregistration_files (
    "CarId" TEXT NOT NULL,
    "TwodimensionCodeInfoValidPeriodExpirdate" TEXT NOT NULL,
    "fileUuid" TEXT NOT NULL,
    PRIMARY KEY ("CarId", "TwodimensionCodeInfoValidPeriodExpirdate", "fileUuid")
);

CREATE TABLE IF NOT EXISTS public.car_ins_sheet_ichiban_cars (
    id_cars TEXT,
    "ElectCertMgNo" TEXT NOT NULL,
    "ElectCertPublishdateE" TEXT NOT NULL,
    "ElectCertPublishdateY" TEXT NOT NULL,
    "ElectCertPublishdateM" TEXT NOT NULL,
    "ElectCertPublishdateD" TEXT NOT NULL,
    PRIMARY KEY ("ElectCertMgNo", "ElectCertPublishdateE", "ElectCertPublishdateY", "ElectCertPublishdateM", "ElectCertPublishdateD")
);

CREATE TABLE IF NOT EXISTS public.car_ins_sheet_ichiban_cars_a (
    id_cars TEXT,
    "ElectCertMgNo" TEXT NOT NULL,
    "GrantdateE" TEXT NOT NULL,
    "GrantdateY" TEXT NOT NULL,
    "GrantdateM" TEXT NOT NULL,
    "GrantdateD" TEXT NOT NULL,
    PRIMARY KEY ("ElectCertMgNo", "GrantdateE", "GrantdateY", "GrantdateM", "GrantdateD")
);

-- ============================================================================
-- CAR REGISTRY TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.ichiban_cars (
    id TEXT NOT NULL,
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
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.dtako_cars_ichiban_cars (
    id_dtako TEXT NOT NULL,
    id TEXT,
    PRIMARY KEY (id_dtako)
);

-- ============================================================================
-- KUDGURI TABLES (Vehicle Tracking System)
-- ============================================================================
-- Parent table
CREATE TABLE IF NOT EXISTS public.kudguri (
    uuid TEXT NOT NULL,
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

-- Child table: Ferry/Cost tracking
CREATE TABLE IF NOT EXISTS public.kudgcst (
    uuid TEXT NOT NULL,
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

-- Child table: Fuel/Refill tracking
CREATE TABLE IF NOT EXISTS public.kudgfry (
    uuid TEXT NOT NULL,
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

-- Child table: Event/Journey tracking
CREATE TABLE IF NOT EXISTS public.kudgful (
    uuid TEXT NOT NULL,
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

-- Child table: Vehicle telemetry (119 columns)
CREATE TABLE IF NOT EXISTS public.kudgivt (
    uuid TEXT NOT NULL,
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

-- Child table: Section/Route tracking
CREATE TABLE IF NOT EXISTS public.kudgsir (
    uuid TEXT NOT NULL,
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

-- ============================================================================
-- SALES TABLES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.uriage (
    name TEXT NOT NULL,
    bumon TEXT NOT NULL,
    kingaku INTEGER,
    type INTEGER,
    cam INTEGER,
    date TEXT NOT NULL,
    PRIMARY KEY (name, bumon, date)
);

CREATE TABLE IF NOT EXISTS public.uriage_jisha (
    bumon TEXT NOT NULL,
    kingaku INTEGER,
    type INTEGER,
    date TEXT NOT NULL,
    PRIMARY KEY (bumon, date)
);

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS
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

-- ============================================================================
-- INDEXES (Performance optimization)
-- ============================================================================
CREATE INDEX idx_kudgcst_kudguri_uuid ON public.kudgcst("kudguriUuid");
CREATE INDEX idx_kudgfry_kudguri_uuid ON public.kudgfry("kudguriUuid");
CREATE INDEX idx_kudgful_kudguri_uuid ON public.kudgful("kudguriUuid");
CREATE INDEX idx_kudgivt_kudguri_uuid ON public.kudgivt("kudguriUuid");
CREATE INDEX idx_kudgsir_kudguri_uuid ON public.kudgsir("kudguriUuid");

CREATE INDEX idx_car_inspection_car_id ON public.car_inspection("CarId");
CREATE INDEX idx_car_inspection_files_elect_cert ON public.car_inspection_files("ElectCertMgNo");
CREATE INDEX idx_ichiban_cars_id4 ON public.ichiban_cars(id4);
CREATE INDEX idx_cam_files_date ON public.cam_files(date);
CREATE INDEX idx_uriage_date ON public.uriage(date);
