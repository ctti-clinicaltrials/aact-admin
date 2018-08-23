--
-- PostgreSQL database dump
--

-- Dumped from database version 10.4
-- Dumped by pg_dump version 10.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: admin; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA admin;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: data_definitions; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.data_definitions (
    id integer NOT NULL,
    db_section character varying,
    table_name character varying,
    column_name character varying,
    data_type character varying,
    source character varying,
    ctti_note text,
    nlm_link character varying,
    row_count integer,
    enumerations json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: data_definitions_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.data_definitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.data_definitions_id_seq OWNED BY admin.data_definitions.id;


--
-- Name: db_user_activities; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.db_user_activities (
    id integer NOT NULL,
    username character varying,
    event_count integer,
    when_recorded timestamp without time zone,
    unit_of_time character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: db_user_activities_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.db_user_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: db_user_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.db_user_activities_id_seq OWNED BY admin.db_user_activities.id;


--
-- Name: enumerations; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.enumerations (
    id integer NOT NULL,
    table_name character varying,
    column_name character varying,
    column_value character varying,
    value_count integer,
    value_percent numeric,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: enumerations_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.enumerations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enumerations_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.enumerations_id_seq OWNED BY admin.enumerations.id;


--
-- Name: health_checks; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.health_checks (
    id integer NOT NULL,
    query text,
    cost character varying,
    actual_time double precision,
    row_count integer,
    description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: health_checks_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.health_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.health_checks_id_seq OWNED BY admin.health_checks.id;


--
-- Name: public_announcements; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.public_announcements (
    id integer NOT NULL,
    description character varying,
    is_sticky boolean
);


--
-- Name: public_announcements_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.public_announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.public_announcements_id_seq OWNED BY admin.public_announcements.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: use_case_attachments; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.use_case_attachments (
    id integer NOT NULL,
    use_case_id integer,
    file_name character varying,
    content_type character varying,
    file_contents bytea,
    is_image boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: use_case_attachments_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.use_case_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.use_case_attachments_id_seq OWNED BY admin.use_case_attachments.id;


--
-- Name: use_case_datasets; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.use_case_datasets (
    id integer NOT NULL,
    use_case_id integer,
    dataset_type character varying,
    name character varying,
    description text
);


--
-- Name: use_case_datasets_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.use_case_datasets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.use_case_datasets_id_seq OWNED BY admin.use_case_datasets.id;


--
-- Name: use_case_publications; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.use_case_publications (
    id integer NOT NULL,
    use_case_id integer,
    name character varying,
    url character varying
);


--
-- Name: use_case_publications_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.use_case_publications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_publications_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.use_case_publications_id_seq OWNED BY admin.use_case_publications.id;


--
-- Name: use_cases; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.use_cases (
    id integer NOT NULL,
    status character varying,
    completion_date date,
    title character varying,
    year integer,
    brief_summary character varying,
    investigators character varying,
    organizations character varying,
    url character varying,
    detailed_description text,
    protocol text,
    issues text,
    study_selection_criteria text,
    submitter_name character varying,
    contact_info character varying,
    email character varying,
    image bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: use_cases_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.use_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.use_cases_id_seq OWNED BY admin.use_cases.id;


--
-- Name: user_events; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.user_events (
    id integer NOT NULL,
    email character varying,
    event_type character varying,
    description text,
    file_names character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_events_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.user_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_events_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.user_events_id_seq OWNED BY admin.user_events.id;


--
-- Name: users; Type: TABLE; Schema: admin; Owner: -
--

CREATE TABLE admin.users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    first_name character varying,
    last_name character varying,
    username character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    db_activity integer,
    last_db_activity timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: admin; Owner: -
--

CREATE SEQUENCE admin.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: admin; Owner: -
--

ALTER SEQUENCE admin.users_id_seq OWNED BY admin.users.id;


--
-- Name: data_definitions id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.data_definitions ALTER COLUMN id SET DEFAULT nextval('admin.data_definitions_id_seq'::regclass);


--
-- Name: db_user_activities id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.db_user_activities ALTER COLUMN id SET DEFAULT nextval('admin.db_user_activities_id_seq'::regclass);


--
-- Name: enumerations id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.enumerations ALTER COLUMN id SET DEFAULT nextval('admin.enumerations_id_seq'::regclass);


--
-- Name: health_checks id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.health_checks ALTER COLUMN id SET DEFAULT nextval('admin.health_checks_id_seq'::regclass);


--
-- Name: public_announcements id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.public_announcements ALTER COLUMN id SET DEFAULT nextval('admin.public_announcements_id_seq'::regclass);


--
-- Name: use_case_attachments id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_attachments ALTER COLUMN id SET DEFAULT nextval('admin.use_case_attachments_id_seq'::regclass);


--
-- Name: use_case_datasets id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_datasets ALTER COLUMN id SET DEFAULT nextval('admin.use_case_datasets_id_seq'::regclass);


--
-- Name: use_case_publications id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_publications ALTER COLUMN id SET DEFAULT nextval('admin.use_case_publications_id_seq'::regclass);


--
-- Name: use_cases id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_cases ALTER COLUMN id SET DEFAULT nextval('admin.use_cases_id_seq'::regclass);


--
-- Name: user_events id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.user_events ALTER COLUMN id SET DEFAULT nextval('admin.user_events_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.users ALTER COLUMN id SET DEFAULT nextval('admin.users_id_seq'::regclass);


--
-- Name: data_definitions data_definitions_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.data_definitions
    ADD CONSTRAINT data_definitions_pkey PRIMARY KEY (id);


--
-- Name: db_user_activities db_user_activities_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.db_user_activities
    ADD CONSTRAINT db_user_activities_pkey PRIMARY KEY (id);


--
-- Name: enumerations enumerations_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.enumerations
    ADD CONSTRAINT enumerations_pkey PRIMARY KEY (id);


--
-- Name: health_checks health_checks_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.health_checks
    ADD CONSTRAINT health_checks_pkey PRIMARY KEY (id);


--
-- Name: public_announcements public_announcements_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.public_announcements
    ADD CONSTRAINT public_announcements_pkey PRIMARY KEY (id);


--
-- Name: use_case_attachments use_case_attachments_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_attachments
    ADD CONSTRAINT use_case_attachments_pkey PRIMARY KEY (id);


--
-- Name: use_case_datasets use_case_datasets_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_datasets
    ADD CONSTRAINT use_case_datasets_pkey PRIMARY KEY (id);


--
-- Name: use_case_publications use_case_publications_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_case_publications
    ADD CONSTRAINT use_case_publications_pkey PRIMARY KEY (id);


--
-- Name: use_cases use_cases_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.use_cases
    ADD CONSTRAINT use_cases_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: admin; Owner: -
--

ALTER TABLE ONLY admin.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_admin.use_case_datasets_on_dataset_type; Type: INDEX; Schema: admin; Owner: -
--

CREATE INDEX "index_admin.use_case_datasets_on_dataset_type" ON admin.use_case_datasets USING btree (dataset_type);


--
-- Name: index_admin.use_case_datasets_on_name; Type: INDEX; Schema: admin; Owner: -
--

CREATE INDEX "index_admin.use_case_datasets_on_name" ON admin.use_case_datasets USING btree (name);


--
-- Name: index_admin.use_cases_on_completion_date; Type: INDEX; Schema: admin; Owner: -
--

CREATE INDEX "index_admin.use_cases_on_completion_date" ON admin.use_cases USING btree (completion_date);


--
-- Name: index_admin.use_cases_on_organizations; Type: INDEX; Schema: admin; Owner: -
--

CREATE INDEX "index_admin.use_cases_on_organizations" ON admin.use_cases USING btree (organizations);


--
-- Name: index_admin.use_cases_on_year; Type: INDEX; Schema: admin; Owner: -
--

CREATE INDEX "index_admin.use_cases_on_year" ON admin.use_cases USING btree (year);


--
-- Name: index_admin.users_on_confirmation_token; Type: INDEX; Schema: admin; Owner: -
--

CREATE UNIQUE INDEX "index_admin.users_on_confirmation_token" ON admin.users USING btree (confirmation_token);


--
-- Name: index_admin.users_on_email; Type: INDEX; Schema: admin; Owner: -
--

CREATE UNIQUE INDEX "index_admin.users_on_email" ON admin.users USING btree (email);


--
-- Name: index_admin.users_on_reset_password_token; Type: INDEX; Schema: admin; Owner: -
--

CREATE UNIQUE INDEX "index_admin.users_on_reset_password_token" ON admin.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: admin; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON admin.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO ctgov, support, admin, public;

INSERT INTO schema_migrations (version) VALUES ('20160214191640');

INSERT INTO schema_migrations (version) VALUES ('20160912000000');

INSERT INTO schema_migrations (version) VALUES ('20180226142044');

INSERT INTO schema_migrations (version) VALUES ('20180427144951');

INSERT INTO schema_migrations (version) VALUES ('20180813174540');

