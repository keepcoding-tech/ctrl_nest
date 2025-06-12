--
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Jun 10 12:26:27 2025
--
;
--
-- Table: migrations
--
CREATE TABLE "migrations" (
  "id" serial NOT NULL,
  "version" character(5) NOT NULL,
  "code_name" character varying(24) NOT NULL,
  "applied_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "migrations_version" UNIQUE ("version")
);

;
--
-- Table: users
--
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "username" character varying(50) NOT NULL,
  "password" character(60) NOT NULL,
  "role" character varying(10) NOT NULL,
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_username" UNIQUE ("username")
);

;
