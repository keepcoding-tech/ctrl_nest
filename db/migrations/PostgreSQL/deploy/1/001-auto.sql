--
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sun Sep  7 12:12:30 2025
--
;
--
-- Table: migrations
--
CREATE TABLE "migrations" (
  "uid" serial NOT NULL,
  "dbix_version" character varying(50) NOT NULL,
  "version" character(5) NOT NULL,
  "code_name" character varying(24) NOT NULL,
  "applied_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("uid"),
  CONSTRAINT "migrations_version" UNIQUE ("version")
);

;
--
-- Table: users
--
CREATE TABLE "users" (
  "uid" serial NOT NULL,
  "username" character varying(50) NOT NULL,
  "password" character(60) NOT NULL,
  "role" character varying(10) NOT NULL,
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("uid"),
  CONSTRAINT "users_username" UNIQUE ("username")
);

;
--
-- Table: access_codes
--
CREATE TABLE "access_codes" (
  "uid" serial NOT NULL,
  "code" character(8) NOT NULL,
  "title" character varying(65),
  "expires_in" integer NOT NULL,
  "type" integer NOT NULL,
  "is_reusable" bit DEFAULT '0' NOT NULL,
  "is_expired" bit DEFAULT '0' NOT NULL,
  "created_by" integer NOT NULL,
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("uid"),
  CONSTRAINT "access_codes_code" UNIQUE ("code")
);
CREATE INDEX "access_codes_idx_created_by" on "access_codes" ("created_by");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "access_codes" ADD CONSTRAINT "access_codes_fk_created_by" FOREIGN KEY ("created_by")
  REFERENCES "users" ("uid") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
