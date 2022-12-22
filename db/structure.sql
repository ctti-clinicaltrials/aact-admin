--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5 (Homebrew)
-- Dumped by pg_dump version 14.5 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: ctgov; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA ctgov;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: attachments; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.attachments (
    id integer NOT NULL,
    project_id integer,
    file_name character varying,
    content_type character varying,
    file_contents bytea,
    is_image boolean,
    description text,
    source text,
    original_file_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attachments_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.attachments_id_seq OWNED BY ctgov.attachments.id;


--
-- Name: data_definitions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.data_definitions (
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
    updated_at timestamp without time zone NOT NULL,
    db_schema character varying
);


--
-- Name: data_definitions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.data_definitions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: data_definitions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.data_definitions_id_seq OWNED BY ctgov.data_definitions.id;


--
-- Name: datasets; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.datasets (
    id integer NOT NULL,
    project_id integer,
    schema_name character varying,
    table_name character varying,
    dataset_type character varying,
    file_name character varying,
    content_type character varying,
    name character varying,
    file_contents bytea,
    url character varying,
    made_available_on date,
    description text,
    source text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: datasets_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.datasets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.datasets_id_seq OWNED BY ctgov.datasets.id;


--
-- Name: db_user_activities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.db_user_activities (
    id integer NOT NULL,
    username character varying,
    event_count integer,
    when_recorded timestamp without time zone,
    unit_of_time character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: db_user_activities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.db_user_activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: db_user_activities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.db_user_activities_id_seq OWNED BY ctgov.db_user_activities.id;


--
-- Name: enumerations; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.enumerations (
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
-- Name: enumerations_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.enumerations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enumerations_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.enumerations_id_seq OWNED BY ctgov.enumerations.id;


--
-- Name: faqs; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.faqs (
    id integer NOT NULL,
    project_id integer,
    question character varying,
    answer text,
    citation character varying,
    url character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: faqs_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.faqs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: faqs_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.faqs_id_seq OWNED BY ctgov.faqs.id;


--
-- Name: health_checks; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.health_checks (
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
-- Name: health_checks_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.health_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: health_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.health_checks_id_seq OWNED BY ctgov.health_checks.id;


--
-- Name: notices; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.notices (
    id integer NOT NULL,
    body character varying,
    user_id integer,
    title character varying,
    send_emails boolean,
    emails_sent_at timestamp without time zone,
    visible boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: notices_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.notices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notices_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.notices_id_seq OWNED BY ctgov.notices.id;


--
-- Name: projects; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.projects (
    id integer NOT NULL,
    status character varying,
    start_date date,
    completion_date date,
    schema_name character varying,
    data_available boolean,
    migration_file_name character varying,
    name character varying,
    year integer,
    aact_version character varying,
    brief_summary character varying,
    investigators character varying,
    organizations character varying,
    url character varying,
    description text,
    protocol text,
    issues text,
    study_selection_criteria text,
    submitter_name character varying,
    contact_info character varying,
    contact_url character varying,
    email character varying,
    image bytea,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.projects_id_seq OWNED BY ctgov.projects.id;


--
-- Name: public_announcements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.public_announcements (
    id integer NOT NULL,
    description character varying,
    is_sticky boolean
);


--
-- Name: public_announcements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.public_announcements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.public_announcements_id_seq OWNED BY ctgov.public_announcements.id;


--
-- Name: publications; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.publications (
    id integer NOT NULL,
    project_id integer,
    pub_type character varying,
    journal_name character varying,
    title character varying,
    url character varying,
    citation character varying,
    pmid character varying,
    pmcid character varying,
    doi character varying,
    publication_date date,
    abstract text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.publications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.publications_id_seq OWNED BY ctgov.publications.id;


--
-- Name: releases; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.releases (
    id integer NOT NULL,
    title character varying,
    subtitle character varying,
    released_on date,
    body text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: releases_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.releases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: releases_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.releases_id_seq OWNED BY ctgov.releases.id;


--
-- Name: saved_queries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.saved_queries (
    id integer NOT NULL,
    title character varying,
    description character varying,
    sql character varying,
    public boolean,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: saved_queries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.saved_queries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saved_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.saved_queries_id_seq OWNED BY ctgov.saved_queries.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: table_saved_queries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.table_saved_queries (
    id integer NOT NULL,
    title character varying,
    description character varying,
    sql character varying,
    public boolean,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: table_saved_queries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.table_saved_queries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: table_saved_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.table_saved_queries_id_seq OWNED BY ctgov.table_saved_queries.id;


--
-- Name: use_case_attachments; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_case_attachments (
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
-- Name: use_case_attachments_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_case_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_case_attachments_id_seq OWNED BY ctgov.use_case_attachments.id;


--
-- Name: use_case_datasets; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_case_datasets (
    id integer NOT NULL,
    use_case_id integer,
    dataset_type character varying,
    name character varying,
    description text
);


--
-- Name: use_case_datasets_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_case_datasets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_datasets_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_case_datasets_id_seq OWNED BY ctgov.use_case_datasets.id;


--
-- Name: use_case_publications; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_case_publications (
    id integer NOT NULL,
    use_case_id integer,
    name character varying,
    url character varying
);


--
-- Name: use_case_publications_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_case_publications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_case_publications_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_case_publications_id_seq OWNED BY ctgov.use_case_publications.id;


--
-- Name: use_cases; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.use_cases (
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
-- Name: use_cases_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.use_cases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: use_cases_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.use_cases_id_seq OWNED BY ctgov.use_cases.id;


--
-- Name: user_events; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.user_events (
    id integer NOT NULL,
    email character varying,
    event_type character varying,
    description text,
    file_names character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_events_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.user_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_events_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.user_events_id_seq OWNED BY ctgov.user_events.id;


--
-- Name: users; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.users (
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
    last_db_activity timestamp without time zone,
    admin boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.users_id_seq OWNED BY ctgov.users.id;


--
-- Name: attachments id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.attachments ALTER COLUMN id SET DEFAULT nextval('ctgov.attachments_id_seq'::regclass);


--
-- Name: data_definitions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.data_definitions ALTER COLUMN id SET DEFAULT nextval('ctgov.data_definitions_id_seq'::regclass);


--
-- Name: datasets id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.datasets ALTER COLUMN id SET DEFAULT nextval('ctgov.datasets_id_seq'::regclass);


--
-- Name: db_user_activities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.db_user_activities ALTER COLUMN id SET DEFAULT nextval('ctgov.db_user_activities_id_seq'::regclass);


--
-- Name: enumerations id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations ALTER COLUMN id SET DEFAULT nextval('ctgov.enumerations_id_seq'::regclass);


--
-- Name: faqs id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.faqs ALTER COLUMN id SET DEFAULT nextval('ctgov.faqs_id_seq'::regclass);


--
-- Name: health_checks id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks ALTER COLUMN id SET DEFAULT nextval('ctgov.health_checks_id_seq'::regclass);


--
-- Name: notices id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.notices ALTER COLUMN id SET DEFAULT nextval('ctgov.notices_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.projects ALTER COLUMN id SET DEFAULT nextval('ctgov.projects_id_seq'::regclass);


--
-- Name: public_announcements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.public_announcements ALTER COLUMN id SET DEFAULT nextval('ctgov.public_announcements_id_seq'::regclass);


--
-- Name: publications id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.publications ALTER COLUMN id SET DEFAULT nextval('ctgov.publications_id_seq'::regclass);


--
-- Name: releases id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.releases ALTER COLUMN id SET DEFAULT nextval('ctgov.releases_id_seq'::regclass);


--
-- Name: saved_queries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries ALTER COLUMN id SET DEFAULT nextval('ctgov.saved_queries_id_seq'::regclass);


--
-- Name: table_saved_queries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.table_saved_queries ALTER COLUMN id SET DEFAULT nextval('ctgov.table_saved_queries_id_seq'::regclass);


--
-- Name: use_case_attachments id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_attachments ALTER COLUMN id SET DEFAULT nextval('ctgov.use_case_attachments_id_seq'::regclass);


--
-- Name: use_case_datasets id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_datasets ALTER COLUMN id SET DEFAULT nextval('ctgov.use_case_datasets_id_seq'::regclass);


--
-- Name: use_case_publications id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_publications ALTER COLUMN id SET DEFAULT nextval('ctgov.use_case_publications_id_seq'::regclass);


--
-- Name: use_cases id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_cases ALTER COLUMN id SET DEFAULT nextval('ctgov.use_cases_id_seq'::regclass);


--
-- Name: user_events id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.user_events ALTER COLUMN id SET DEFAULT nextval('ctgov.user_events_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.users ALTER COLUMN id SET DEFAULT nextval('ctgov.users_id_seq'::regclass);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: data_definitions data_definitions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.data_definitions
    ADD CONSTRAINT data_definitions_pkey PRIMARY KEY (id);


--
-- Name: datasets datasets_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.datasets
    ADD CONSTRAINT datasets_pkey PRIMARY KEY (id);


--
-- Name: db_user_activities db_user_activities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.db_user_activities
    ADD CONSTRAINT db_user_activities_pkey PRIMARY KEY (id);


--
-- Name: enumerations enumerations_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations
    ADD CONSTRAINT enumerations_pkey PRIMARY KEY (id);


--
-- Name: faqs faqs_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.faqs
    ADD CONSTRAINT faqs_pkey PRIMARY KEY (id);


--
-- Name: health_checks health_checks_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks
    ADD CONSTRAINT health_checks_pkey PRIMARY KEY (id);


--
-- Name: notices notices_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: public_announcements public_announcements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.public_announcements
    ADD CONSTRAINT public_announcements_pkey PRIMARY KEY (id);


--
-- Name: publications publications_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);


--
-- Name: saved_queries saved_queries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries
    ADD CONSTRAINT saved_queries_pkey PRIMARY KEY (id);


--
-- Name: table_saved_queries table_saved_queries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.table_saved_queries
    ADD CONSTRAINT table_saved_queries_pkey PRIMARY KEY (id);


--
-- Name: use_case_attachments use_case_attachments_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_attachments
    ADD CONSTRAINT use_case_attachments_pkey PRIMARY KEY (id);


--
-- Name: use_case_datasets use_case_datasets_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_datasets
    ADD CONSTRAINT use_case_datasets_pkey PRIMARY KEY (id);


--
-- Name: use_case_publications use_case_publications_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_case_publications
    ADD CONSTRAINT use_case_publications_pkey PRIMARY KEY (id);


--
-- Name: use_cases use_cases_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.use_cases
    ADD CONSTRAINT use_cases_pkey PRIMARY KEY (id);


--
-- Name: user_events user_events_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.user_events
    ADD CONSTRAINT user_events_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_ctgov.use_case_datasets_on_dataset_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.use_case_datasets_on_dataset_type" ON ctgov.use_case_datasets USING btree (dataset_type);


--
-- Name: index_ctgov.use_case_datasets_on_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.use_case_datasets_on_name" ON ctgov.use_case_datasets USING btree (name);


--
-- Name: index_ctgov.use_cases_on_completion_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.use_cases_on_completion_date" ON ctgov.use_cases USING btree (completion_date);


--
-- Name: index_ctgov.use_cases_on_organizations; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.use_cases_on_organizations" ON ctgov.use_cases USING btree (organizations);


--
-- Name: index_ctgov.use_cases_on_year; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.use_cases_on_year" ON ctgov.use_cases USING btree (year);


--
-- Name: index_ctgov.users_on_confirmation_token; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX "index_ctgov.users_on_confirmation_token" ON ctgov.users USING btree (confirmation_token);


--
-- Name: index_ctgov.users_on_email; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX "index_ctgov.users_on_email" ON ctgov.users USING btree (email);


--
-- Name: index_ctgov.users_on_reset_password_token; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX "index_ctgov.users_on_reset_password_token" ON ctgov.users USING btree (reset_password_token);


--
-- Name: index_projects_on_completion_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_completion_date ON ctgov.projects USING btree (completion_date);


--
-- Name: index_projects_on_data_available; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_data_available ON ctgov.projects USING btree (data_available);


--
-- Name: index_projects_on_investigators; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_investigators ON ctgov.projects USING btree (investigators);


--
-- Name: index_projects_on_organizations; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_organizations ON ctgov.projects USING btree (organizations);


--
-- Name: index_projects_on_start_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_start_date ON ctgov.projects USING btree (start_date);


--
-- Name: index_projects_on_year; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_projects_on_year ON ctgov.projects USING btree (year);


--
-- Name: index_saved_queries_on_user_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_saved_queries_on_user_id ON ctgov.saved_queries USING btree (user_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON ctgov.schema_migrations USING btree (version);


--
-- Name: saved_queries fk_rails_add691a365; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries
    ADD CONSTRAINT fk_rails_add691a365 FOREIGN KEY (user_id) REFERENCES ctgov.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO ctgov, support, public;

INSERT INTO schema_migrations (version) VALUES ('20160214191640');

INSERT INTO schema_migrations (version) VALUES ('20160912000000');

INSERT INTO schema_migrations (version) VALUES ('20180226142044');

INSERT INTO schema_migrations (version) VALUES ('20180427144951');

INSERT INTO schema_migrations (version) VALUES ('20180813174540');

INSERT INTO schema_migrations (version) VALUES ('20181108174440');

INSERT INTO schema_migrations (version) VALUES ('20181208174440');

INSERT INTO schema_migrations (version) VALUES ('20190321174440');

INSERT INTO schema_migrations (version) VALUES ('20211027220743');

INSERT INTO schema_migrations (version) VALUES ('20211102194357');

INSERT INTO schema_migrations (version) VALUES ('20211109190158');

INSERT INTO schema_migrations (version) VALUES ('20221005135246');

INSERT INTO schema_migrations (version) VALUES ('20221018210501');

