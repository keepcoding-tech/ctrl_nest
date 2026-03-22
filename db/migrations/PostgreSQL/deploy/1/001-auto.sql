--
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sun Mar 22 13:25:53 2026
--
;
--
-- Table: users
--
CREATE TABLE "users" (
  "uid" serial NOT NULL,
  "username" character varying(64) NOT NULL,
  "email" character varying(256) NOT NULL,
  "password" character(60) NOT NULL,
  "role" character varying(12) NOT NULL,
  "avatar_path" character varying(256),
  "first_name" character varying(64) NOT NULL,
  "last_name" character varying(64) NOT NULL,
  "occupation" character varying(64),
  "bio" character varying(164),
  "mobile_phone" character varying(16),
  "fix_phone" character varying(16),
  "contact_email" character varying(256),
  "country" character(2),
  "region" character varying(128),
  "city" character varying(128),
  "address" character varying(256),
  "zip_code" character varying(16),
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("uid"),
  CONSTRAINT "users_username_email" UNIQUE ("username", "email")
);

;
--
-- Table: access_codes
--
CREATE TABLE "access_codes" (
  "uid" serial NOT NULL,
  "code" character(8) NOT NULL,
  "title" character varying(64),
  "type" integer NOT NULL,
  "expires_in" integer NOT NULL,
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
