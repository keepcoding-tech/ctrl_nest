--
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Jun  5 18:17:36 2025
--
;
--
-- Table: access_code
--
CREATE TABLE "access_code" (
  "id" serial NOT NULL,
  "code" character(8) NOT NULL,
  "code_name" character varying(60),
  "expires_at" timestamptz NOT NULL,
  "is_expired" bit DEFAULT '0' NOT NULL,
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "access_code_code" UNIQUE ("code")
);

;
--
-- Table: migrations
--
CREATE TABLE "migrations" (
  "id" serial NOT NULL,
  "version" character(5) NOT NULL,
  "code_name" character varying(24) NOT NULL,
  "applied_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "migrations_version" UNIQUE ("version")
);

;
--
-- Table: users
--
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "email" character varying(320) NOT NULL,
  "first_name" character varying(50) NOT NULL,
  "middle_name" character varying(50),
  "last_name" character varying(50) NOT NULL,
  "username" character varying(24) NOT NULL,
  "password" character(60) NOT NULL,
  "role" character varying(10) NOT NULL,
  "created_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_email_username" UNIQUE ("email", "username")
);

;
