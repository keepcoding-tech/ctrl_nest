-- Convert schema '/Users/keepie/Repository/ctrl_nest/db/migrations/_source/deploy/1/001-auto.yml' to '/Users/keepie/Repository/ctrl_nest/db/migrations/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
CREATE TABLE "access_code" (
  "id" serial NOT NULL,
  "code" character(8) NOT NULL,
  "title" character varying(60),
  "expires_in" integer NOT NULL,
  "type" integer NOT NULL,
  "is_reusable" bit DEFAULT '0' NOT NULL,
  "is_expired" bit DEFAULT '0' NOT NULL,
  "created_by" character varying(50) NOT NULL,
  "created_at" timestamptz DEFAULT CURRENT_TIMESTAMP NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "access_code_code" UNIQUE ("code")
);

;

COMMIT;

