--
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed May 21 15:42:53 2025
--
;
--
-- Table: migrations
--
CREATE TABLE "migrations" (
  "id" serial NOT NULL,
  "version" character varying(50) NOT NULL,
  "applied_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "description" text NOT NULL,
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
  "created_at" timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_username" UNIQUE ("username")
);

;
