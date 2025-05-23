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


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: support; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA support;


--
-- Name: category_insert_function(); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.category_insert_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          INSERT INTO ctgov_v2.search_results (id, nct_id, name, created_at, updated_at, grouping, study_search_id)

          VALUES (NEW.id, NEW.nct_id, NEW.name, NEW.created_at, NEW.updated_at, NEW.grouping, NEW.study_search_id);
          RETURN NEW;
        END;
        $$;


--
-- Name: ids_for_org(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.ids_for_org(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT nct_id FROM responsible_parties WHERE lower(affiliation) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM facilities WHERE lower(name) like lower($1) or lower(city) like lower($1) or lower(state) like lower($1) or lower(country) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM sponsors WHERE lower(name) like lower($1)
      UNION
      SELECT DISTINCT nct_id FROM result_contacts WHERE lower(organization) like lower($1)
      ;
      $_$;


--
-- Name: ids_for_term(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.ids_for_term(character varying) RETURNS TABLE(nct_id character varying)
    LANGUAGE sql
    AS $_$
        SELECT DISTINCT nct_id FROM browse_conditions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM browse_interventions WHERE downcase_mesh_term like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM studies WHERE lower(brief_title) like lower($1)
        UNION
        SELECT DISTINCT nct_id FROM keywords WHERE lower(name) like lower($1)
        ;
        $_$;


--
-- Name: study_summaries_for_condition(character varying); Type: FUNCTION; Schema: ctgov; Owner: -
--

CREATE FUNCTION ctgov.study_summaries_for_condition(character varying) RETURNS TABLE(nct_id character varying, title text, recruitment character varying, were_results_reported boolean, conditions text, interventions text, gender character varying, age text, phase character varying, enrollment integer, study_type character varying, sponsors text, other_ids text, study_first_submitted_date date, start_date date, completion_month_year character varying, last_update_submitted_date date, verification_month_year character varying, results_first_submitted_date date, acronym character varying, primary_completion_month_year character varying, outcome_measures text, disposition_first_submitted_date date, allocation character varying, intervention_model character varying, observational_model character varying, primary_purpose character varying, time_perspective character varying, masking character varying, masking_description text, intervention_model_description text, subject_masked boolean, caregiver_masked boolean, investigator_masked boolean, outcomes_assessor_masked boolean, number_of_facilities integer)
    LANGUAGE sql
    AS $_$
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.mesh_term,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN browse_conditions         bc ON s.nct_id = bc.nct_id and bc.downcase_mesh_term  like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id
     UNION
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          bc.name,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as design_outcomes,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN conditions                bc ON s.nct_id = bc.nct_id and bc.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values    cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions       c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions    i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors         sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities        e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information   id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes  o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs              d  ON s.nct_id = d.nct_id
     UNION
      SELECT DISTINCT s.nct_id,
          s.brief_title,
          s.overall_status,
          cv.were_results_reported,
          k.name,
          i.names as interventions,
          e.gender,
          CASE
            WHEN e.minimum_age = 'N/A' AND e.maximum_age = 'N/A' THEN 'No age restriction'
            WHEN e.minimum_age != 'N/A' AND e.maximum_age = 'N/A' THEN concat(e.minimum_age, ' and older')
            WHEN e.minimum_age = 'N/A' AND e.maximum_age != 'N/A' THEN concat('up to ', e.maximum_age)
            ELSE concat(e.minimum_age, ' to ', e.maximum_age)
          END,
          CASE
            WHEN s.phase='N/A' THEN NULL
            ELSE s.phase
          END,
          s.enrollment,
          s.study_type,
          sp.names as sponsors,
          id.names as id_values,
          s.study_first_submitted_date,
          s.start_date,
          s.completion_month_year,
          s.last_update_submitted_date,
          s.verification_month_year,
          s.results_first_submitted_date,
          s.acronym,
          s.primary_completion_month_year,
          o.names as outcome_measures,
          s.disposition_first_submitted_date,
          d.allocation,
          d.intervention_model,
          d.observational_model,
          d.primary_purpose,
          d.time_perspective,
          d.masking,
          d.masking_description,
          d.intervention_model_description,
          d.subject_masked,
          d.caregiver_masked,
          d.investigator_masked,
          d.outcomes_assessor_masked,
          cv.number_of_facilities
      FROM studies s
        INNER JOIN keywords k ON s.nct_id = k.nct_id and k.downcase_name like lower($1)
        LEFT OUTER JOIN calculated_values   cv ON s.nct_id = cv.nct_id
        LEFT OUTER JOIN all_conditions      c  ON s.nct_id = c.nct_id
        LEFT OUTER JOIN all_interventions   i  ON s.nct_id = i.nct_id
        LEFT OUTER JOIN all_sponsors        sp ON s.nct_id = sp.nct_id
        LEFT OUTER JOIN eligibilities       e  ON s.nct_id = e.nct_id
        LEFT OUTER JOIN all_id_information  id ON s.nct_id = id.nct_id
        LEFT OUTER JOIN all_design_outcomes o  ON s.nct_id = o.nct_id
        LEFT OUTER JOIN designs             d  ON s.nct_id = d.nct_id
        ;
        $_$;


--
-- Name: count_estimate(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.count_estimate(query text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
      DECLARE
        rec   record;
        ROWS  INTEGER;
      BEGIN
        FOR rec IN EXECUTE 'EXPLAIN ' || query LOOP
          ROWS := SUBSTRING(rec."QUERY PLAN" FROM ' rows=([[:digit:]]+)');
          EXIT WHEN ROWS IS NOT NULL;
      END LOOP;

      RETURN ROWS;
      END
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: browse_conditions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.browse_conditions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);


--
-- Name: all_browse_conditions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_browse_conditions AS
 SELECT browse_conditions.nct_id,
    array_to_string(array_agg(DISTINCT browse_conditions.mesh_term), '|'::text) AS names
   FROM ctgov.browse_conditions
  GROUP BY browse_conditions.nct_id;


--
-- Name: browse_interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.browse_interventions (
    id integer NOT NULL,
    nct_id character varying,
    mesh_term character varying,
    downcase_mesh_term character varying,
    mesh_type character varying
);


--
-- Name: all_browse_interventions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_browse_interventions AS
 SELECT browse_interventions.nct_id,
    array_to_string(array_agg(browse_interventions.mesh_term), '|'::text) AS names
   FROM ctgov.browse_interventions
  GROUP BY browse_interventions.nct_id;


--
-- Name: facilities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facilities (
    id integer NOT NULL,
    nct_id character varying,
    status character varying,
    name character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying,
    latitude numeric(10,6),
    longitude numeric(10,6)
);


--
-- Name: all_cities; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_cities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.city), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


--
-- Name: conditions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.conditions (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: all_conditions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_conditions AS
 SELECT conditions.nct_id,
    array_to_string(array_agg(DISTINCT conditions.name), '|'::text) AS names
   FROM ctgov.conditions
  GROUP BY conditions.nct_id;


--
-- Name: countries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.countries (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    removed boolean
);


--
-- Name: all_countries; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_countries AS
 SELECT countries.nct_id,
    array_to_string(array_agg(DISTINCT countries.name), '|'::text) AS names
   FROM ctgov.countries
  WHERE (countries.removed IS NOT TRUE)
  GROUP BY countries.nct_id;


--
-- Name: design_outcomes; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    measure text,
    time_frame text,
    population character varying,
    description text
);


--
-- Name: all_design_outcomes; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_design_outcomes AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  GROUP BY design_outcomes.nct_id;


--
-- Name: all_facilities; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_facilities AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(facilities.name), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


--
-- Name: design_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_groups (
    id integer NOT NULL,
    nct_id character varying,
    group_type character varying,
    title character varying,
    description text
);


--
-- Name: all_group_types; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_group_types AS
 SELECT design_groups.nct_id,
    array_to_string(array_agg(DISTINCT design_groups.group_type), '|'::text) AS names
   FROM ctgov.design_groups
  GROUP BY design_groups.nct_id;


--
-- Name: id_information; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.id_information (
    id integer NOT NULL,
    nct_id character varying,
    id_source character varying,
    id_value character varying,
    id_type character varying,
    id_type_description character varying,
    id_link character varying
);


--
-- Name: all_id_information; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_id_information AS
 SELECT id_information.nct_id,
    array_to_string(array_agg(DISTINCT id_information.id_value), '|'::text) AS names
   FROM ctgov.id_information
  GROUP BY id_information.nct_id;


--
-- Name: interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.interventions (
    id integer NOT NULL,
    nct_id character varying,
    intervention_type character varying,
    name character varying,
    description text
);


--
-- Name: all_intervention_types; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_intervention_types AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.intervention_type), '|'::text) AS names
   FROM ctgov.interventions
  GROUP BY interventions.nct_id;


--
-- Name: all_interventions; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_interventions AS
 SELECT interventions.nct_id,
    array_to_string(array_agg(interventions.name), '|'::text) AS names
   FROM ctgov.interventions
  GROUP BY interventions.nct_id;


--
-- Name: keywords; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.keywords (
    id integer NOT NULL,
    nct_id character varying,
    name character varying,
    downcase_name character varying
);


--
-- Name: all_keywords; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_keywords AS
 SELECT keywords.nct_id,
    array_to_string(array_agg(DISTINCT keywords.name), '|'::text) AS names
   FROM ctgov.keywords
  GROUP BY keywords.nct_id;


--
-- Name: overall_officials; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.overall_officials (
    id integer NOT NULL,
    nct_id character varying,
    role character varying,
    name character varying,
    affiliation character varying
);


--
-- Name: all_overall_official_affiliations; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_overall_official_affiliations AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.affiliation), '|'::text) AS names
   FROM ctgov.overall_officials
  GROUP BY overall_officials.nct_id;


--
-- Name: all_overall_officials; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_overall_officials AS
 SELECT overall_officials.nct_id,
    array_to_string(array_agg(overall_officials.name), '|'::text) AS names
   FROM ctgov.overall_officials
  GROUP BY overall_officials.nct_id;


--
-- Name: all_primary_outcome_measures; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_primary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'primary'::text)
  GROUP BY design_outcomes.nct_id;


--
-- Name: all_secondary_outcome_measures; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_secondary_outcome_measures AS
 SELECT design_outcomes.nct_id,
    array_to_string(array_agg(DISTINCT design_outcomes.measure), '|'::text) AS names
   FROM ctgov.design_outcomes
  WHERE ((design_outcomes.outcome_type)::text = 'secondary'::text)
  GROUP BY design_outcomes.nct_id;


--
-- Name: sponsors; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.sponsors (
    id integer NOT NULL,
    nct_id character varying,
    agency_class character varying,
    lead_or_collaborator character varying,
    name character varying
);


--
-- Name: all_sponsors; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_sponsors AS
 SELECT sponsors.nct_id,
    array_to_string(array_agg(DISTINCT sponsors.name), '|'::text) AS names
   FROM ctgov.sponsors
  GROUP BY sponsors.nct_id;


--
-- Name: all_states; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.all_states AS
 SELECT facilities.nct_id,
    array_to_string(array_agg(DISTINCT facilities.state), '|'::text) AS names
   FROM ctgov.facilities
  GROUP BY facilities.nct_id;


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
-- Name: baseline_counts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.baseline_counts (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    units character varying,
    scope character varying,
    count integer
);


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.baseline_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.baseline_counts_id_seq OWNED BY ctgov.baseline_counts.id;


--
-- Name: baseline_measurements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.baseline_measurements (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na character varying,
    number_analyzed integer,
    number_analyzed_units character varying,
    population_description character varying,
    calculate_percentage character varying
);


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.baseline_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: baseline_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.baseline_measurements_id_seq OWNED BY ctgov.baseline_measurements.id;


--
-- Name: brief_summaries; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.brief_summaries (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.brief_summaries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brief_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.brief_summaries_id_seq OWNED BY ctgov.brief_summaries.id;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.browse_conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.browse_conditions_id_seq OWNED BY ctgov.browse_conditions.id;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.browse_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browse_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.browse_interventions_id_seq OWNED BY ctgov.browse_interventions.id;


--
-- Name: calculated_values; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.calculated_values (
    id integer NOT NULL,
    nct_id character varying,
    number_of_facilities integer,
    number_of_nsae_subjects integer,
    number_of_sae_subjects integer,
    registered_in_calendar_year integer,
    nlm_download_date date,
    actual_duration integer,
    were_results_reported boolean DEFAULT false,
    months_to_report_results integer,
    has_us_facility boolean,
    has_single_facility boolean DEFAULT false,
    minimum_age_num integer,
    maximum_age_num integer,
    minimum_age_unit character varying,
    maximum_age_unit character varying,
    number_of_primary_outcomes_to_measure integer,
    number_of_secondary_outcomes_to_measure integer,
    number_of_other_outcomes_to_measure integer
);


--
-- Name: calculated_values_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.calculated_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calculated_values_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.calculated_values_id_seq OWNED BY ctgov.calculated_values.id;


--
-- Name: search_results; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.search_results (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    study_search_id integer
);


--
-- Name: categories; Type: VIEW; Schema: ctgov; Owner: -
--

CREATE VIEW ctgov.categories AS
 SELECT search_results.id,
    search_results.nct_id,
    search_results.name,
    search_results.created_at,
    search_results.updated_at,
    search_results."grouping",
    search_results.study_search_id
   FROM ctgov.search_results;


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: central_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.central_contacts (
    id integer NOT NULL,
    nct_id character varying,
    contact_type character varying,
    name character varying,
    phone character varying,
    email character varying,
    phone_extension character varying,
    role character varying
);


--
-- Name: central_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.central_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: central_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.central_contacts_id_seq OWNED BY ctgov.central_contacts.id;


--
-- Name: conditions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.conditions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: conditions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.conditions_id_seq OWNED BY ctgov.conditions.id;


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.countries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.countries_id_seq OWNED BY ctgov.countries.id;


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
-- Name: design_group_interventions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.design_group_interventions (
    id integer NOT NULL,
    nct_id character varying,
    design_group_id integer,
    intervention_id integer
);


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_group_interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_group_interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_group_interventions_id_seq OWNED BY ctgov.design_group_interventions.id;


--
-- Name: design_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_groups_id_seq OWNED BY ctgov.design_groups.id;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.design_outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: design_outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.design_outcomes_id_seq OWNED BY ctgov.design_outcomes.id;


--
-- Name: designs; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.designs (
    id integer NOT NULL,
    nct_id character varying,
    allocation character varying,
    intervention_model character varying,
    observational_model character varying,
    primary_purpose character varying,
    time_perspective character varying,
    masking character varying,
    masking_description text,
    intervention_model_description text,
    subject_masked boolean,
    caregiver_masked boolean,
    investigator_masked boolean,
    outcomes_assessor_masked boolean
);


--
-- Name: designs_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.designs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: designs_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.designs_id_seq OWNED BY ctgov.designs.id;


--
-- Name: detailed_descriptions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.detailed_descriptions (
    id integer NOT NULL,
    nct_id character varying,
    description text
);


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.detailed_descriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detailed_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.detailed_descriptions_id_seq OWNED BY ctgov.detailed_descriptions.id;


--
-- Name: documents; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.documents (
    id integer NOT NULL,
    nct_id character varying,
    document_id character varying,
    document_type character varying,
    url character varying,
    comment text
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.documents_id_seq OWNED BY ctgov.documents.id;


--
-- Name: drop_withdrawals; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.drop_withdrawals (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    period character varying,
    reason character varying,
    count integer,
    drop_withdraw_comment character varying,
    reason_comment character varying,
    count_units integer
);


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.drop_withdrawals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drop_withdrawals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.drop_withdrawals_id_seq OWNED BY ctgov.drop_withdrawals.id;


--
-- Name: eligibilities; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.eligibilities (
    id integer NOT NULL,
    nct_id character varying,
    sampling_method character varying,
    gender character varying,
    minimum_age character varying,
    maximum_age character varying,
    healthy_volunteers boolean,
    population text,
    criteria text,
    gender_description text,
    gender_based boolean,
    adult boolean,
    child boolean,
    older_adult boolean
);


--
-- Name: eligibilities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.eligibilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eligibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.eligibilities_id_seq OWNED BY ctgov.eligibilities.id;


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
-- Name: facilities_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facilities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facilities_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facilities_id_seq OWNED BY ctgov.facilities.id;


--
-- Name: facility_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facility_contacts (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    contact_type character varying,
    name character varying,
    email character varying,
    phone character varying,
    phone_extension character varying
);


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facility_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facility_contacts_id_seq OWNED BY ctgov.facility_contacts.id;


--
-- Name: facility_investigators; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.facility_investigators (
    id integer NOT NULL,
    nct_id character varying,
    facility_id integer,
    role character varying,
    name character varying
);


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.facility_investigators_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_investigators_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.facility_investigators_id_seq OWNED BY ctgov.facility_investigators.id;


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
-- Name: file_downloads; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.file_downloads (
    id integer NOT NULL,
    file_record_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: file_downloads_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.file_downloads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_downloads_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.file_downloads_id_seq OWNED BY ctgov.file_downloads.id;


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
-- Name: id_information_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.id_information_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: id_information_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.id_information_id_seq OWNED BY ctgov.id_information.id;


--
-- Name: intervention_other_names; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.intervention_other_names (
    id integer NOT NULL,
    nct_id character varying,
    intervention_id integer,
    name character varying
);


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.intervention_other_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intervention_other_names_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.intervention_other_names_id_seq OWNED BY ctgov.intervention_other_names.id;


--
-- Name: interventions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.interventions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interventions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.interventions_id_seq OWNED BY ctgov.interventions.id;


--
-- Name: ipd_information_types; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.ipd_information_types (
    id integer NOT NULL,
    nct_id character varying,
    name character varying
);


--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.ipd_information_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ipd_information_types_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.ipd_information_types_id_seq OWNED BY ctgov.ipd_information_types.id;


--
-- Name: keywords_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.keywords_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.keywords_id_seq OWNED BY ctgov.keywords.id;


--
-- Name: links; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.links (
    id integer NOT NULL,
    nct_id character varying,
    url character varying,
    description text
);


--
-- Name: links_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: links_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.links_id_seq OWNED BY ctgov.links.id;


--
-- Name: mesh_headings; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.mesh_headings (
    id integer NOT NULL,
    qualifier character varying,
    heading character varying,
    subcategory character varying
);


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.mesh_headings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_headings_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.mesh_headings_id_seq OWNED BY ctgov.mesh_headings.id;


--
-- Name: mesh_terms; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.mesh_terms (
    id integer NOT NULL,
    qualifier character varying,
    tree_number character varying,
    description character varying,
    mesh_term character varying,
    downcase_mesh_term character varying
);


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.mesh_terms_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mesh_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.mesh_terms_id_seq OWNED BY ctgov.mesh_terms.id;


--
-- Name: milestones; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.milestones (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    title character varying,
    period character varying,
    description text,
    count integer,
    milestone_description character varying,
    count_units character varying
);


--
-- Name: milestones_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.milestones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: milestones_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.milestones_id_seq OWNED BY ctgov.milestones.id;


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
-- Name: outcome_analyses; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_analyses (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    non_inferiority_type character varying,
    non_inferiority_description text,
    param_type character varying,
    param_value numeric,
    dispersion_type character varying,
    dispersion_value numeric,
    p_value_modifier character varying,
    p_value double precision,
    ci_n_sides character varying,
    ci_percent numeric,
    ci_lower_limit numeric,
    ci_upper_limit numeric,
    ci_upper_limit_na_comment character varying,
    p_value_description character varying,
    method character varying,
    method_description text,
    estimate_description text,
    groups_description text,
    other_analysis_description text,
    ci_upper_limit_raw character varying,
    ci_lower_limit_raw character varying,
    p_value_raw character varying
);


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_analyses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_analyses_id_seq OWNED BY ctgov.outcome_analyses.id;


--
-- Name: outcome_analysis_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_analysis_groups (
    id integer NOT NULL,
    nct_id character varying,
    outcome_analysis_id integer,
    result_group_id integer,
    ctgov_group_code character varying
);


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_analysis_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_analysis_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_analysis_groups_id_seq OWNED BY ctgov.outcome_analysis_groups.id;


--
-- Name: outcome_counts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_counts (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
    scope character varying,
    units character varying,
    count integer
);


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_counts_id_seq OWNED BY ctgov.outcome_counts.id;


--
-- Name: outcome_measurements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcome_measurements (
    id integer NOT NULL,
    nct_id character varying,
    outcome_id integer,
    result_group_id integer,
    ctgov_group_code character varying,
    classification character varying,
    category character varying,
    title character varying,
    description text,
    units character varying,
    param_type character varying,
    param_value character varying,
    param_value_num numeric,
    dispersion_type character varying,
    dispersion_value character varying,
    dispersion_value_num numeric,
    dispersion_lower_limit numeric,
    dispersion_upper_limit numeric,
    explanation_of_na text,
    dispersion_upper_limit_raw character varying,
    dispersion_lower_limit_raw character varying
);


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcome_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcome_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcome_measurements_id_seq OWNED BY ctgov.outcome_measurements.id;


--
-- Name: outcomes; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.outcomes (
    id integer NOT NULL,
    nct_id character varying,
    outcome_type character varying,
    title text,
    description text,
    time_frame text,
    population text,
    anticipated_posting_date date,
    anticipated_posting_month_year character varying,
    units character varying,
    units_analyzed character varying,
    dispersion_type character varying,
    param_type character varying
);


--
-- Name: outcomes_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.outcomes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: outcomes_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.outcomes_id_seq OWNED BY ctgov.outcomes.id;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.overall_officials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: overall_officials_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.overall_officials_id_seq OWNED BY ctgov.overall_officials.id;


--
-- Name: participant_flows; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.participant_flows (
    id integer NOT NULL,
    nct_id character varying,
    recruitment_details text,
    pre_assignment_details text,
    units_analyzed character varying
);


--
-- Name: participant_flows_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.participant_flows_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participant_flows_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.participant_flows_id_seq OWNED BY ctgov.participant_flows.id;


--
-- Name: pending_results; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.pending_results (
    id integer NOT NULL,
    nct_id character varying,
    event character varying,
    event_date_description character varying,
    event_date date
);


--
-- Name: pending_results_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.pending_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pending_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.pending_results_id_seq OWNED BY ctgov.pending_results.id;


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
-- Name: provided_documents; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.provided_documents (
    id integer NOT NULL,
    nct_id character varying,
    document_type character varying,
    has_protocol boolean,
    has_icf boolean,
    has_sap boolean,
    document_date date,
    url character varying
);


--
-- Name: provided_documents_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.provided_documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: provided_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.provided_documents_id_seq OWNED BY ctgov.provided_documents.id;


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
-- Name: reported_event_totals; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.reported_event_totals (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    ctgov_group_code character varying NOT NULL,
    event_type character varying,
    classification character varying NOT NULL,
    subjects_affected integer,
    subjects_at_risk integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.reported_event_totals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_event_totals_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.reported_event_totals_id_seq OWNED BY ctgov.reported_event_totals.id;


--
-- Name: reported_events; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.reported_events (
    id integer NOT NULL,
    nct_id character varying,
    result_group_id integer,
    ctgov_group_code character varying,
    time_frame text,
    event_type character varying,
    default_vocab character varying,
    default_assessment character varying,
    subjects_affected integer,
    subjects_at_risk integer,
    description text,
    event_count integer,
    organ_system character varying,
    adverse_event_term character varying,
    frequency_threshold integer,
    vocab character varying,
    assessment character varying
);


--
-- Name: reported_events_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.reported_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_events_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.reported_events_id_seq OWNED BY ctgov.reported_events.id;


--
-- Name: responsible_parties; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.responsible_parties (
    id integer NOT NULL,
    nct_id character varying,
    responsible_party_type character varying,
    name character varying,
    title character varying,
    organization character varying,
    affiliation text,
    old_name_title character varying
);


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.responsible_parties_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responsible_parties_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.responsible_parties_id_seq OWNED BY ctgov.responsible_parties.id;


--
-- Name: result_agreements; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_agreements (
    id integer NOT NULL,
    nct_id character varying,
    pi_employee boolean,
    agreement text,
    restriction_type character varying,
    other_details text,
    restrictive_agreement boolean
);


--
-- Name: result_agreements_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_agreements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_agreements_id_seq OWNED BY ctgov.result_agreements.id;


--
-- Name: result_contacts; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_contacts (
    id integer NOT NULL,
    nct_id character varying,
    organization character varying,
    name character varying,
    phone character varying,
    email character varying,
    extension character varying
);


--
-- Name: result_contacts_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_contacts_id_seq OWNED BY ctgov.result_contacts.id;


--
-- Name: result_groups; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.result_groups (
    id integer NOT NULL,
    nct_id character varying,
    ctgov_group_code character varying,
    result_type character varying,
    title character varying,
    description text,
    outcome_id integer
);


--
-- Name: result_groups_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.result_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.result_groups_id_seq OWNED BY ctgov.result_groups.id;


--
-- Name: retractions; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.retractions (
    id bigint NOT NULL,
    reference_id integer,
    pmid character varying,
    source character varying,
    nct_id character varying
);


--
-- Name: retractions_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.retractions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: retractions_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.retractions_id_seq OWNED BY ctgov.retractions.id;


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
-- Name: search_results_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.search_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.search_results_id_seq OWNED BY ctgov.search_results.id;


--
-- Name: search_term_results; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.search_term_results (
    id bigint NOT NULL,
    nct_id character varying NOT NULL,
    search_term_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: search_term_results_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.search_term_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_term_results_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.search_term_results_id_seq OWNED BY ctgov.search_term_results.id;


--
-- Name: search_terms; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.search_terms (
    id bigint NOT NULL,
    term character varying NOT NULL,
    "group" character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: search_terms_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.search_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.search_terms_id_seq OWNED BY ctgov.search_terms.id;


--
-- Name: sponsors_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.sponsors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sponsors_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.sponsors_id_seq OWNED BY ctgov.sponsors.id;


--
-- Name: studies; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.studies (
    nct_id character varying,
    nlm_download_date_description character varying,
    study_first_submitted_date date,
    results_first_submitted_date date,
    disposition_first_submitted_date date,
    last_update_submitted_date date,
    study_first_submitted_qc_date date,
    study_first_posted_date date,
    study_first_posted_date_type character varying,
    results_first_submitted_qc_date date,
    results_first_posted_date date,
    results_first_posted_date_type character varying,
    disposition_first_submitted_qc_date date,
    disposition_first_posted_date date,
    disposition_first_posted_date_type character varying,
    last_update_submitted_qc_date date,
    last_update_posted_date date,
    last_update_posted_date_type character varying,
    start_month_year character varying,
    start_date_type character varying,
    start_date date,
    verification_month_year character varying,
    verification_date date,
    completion_month_year character varying,
    completion_date_type character varying,
    completion_date date,
    primary_completion_month_year character varying,
    primary_completion_date_type character varying,
    primary_completion_date date,
    target_duration character varying,
    study_type character varying,
    acronym character varying,
    baseline_population text,
    brief_title text,
    official_title text,
    overall_status character varying,
    last_known_status character varying,
    phase character varying,
    enrollment integer,
    enrollment_type character varying,
    source character varying,
    limitations_and_caveats character varying,
    number_of_arms integer,
    number_of_groups integer,
    why_stopped character varying,
    has_expanded_access boolean,
    expanded_access_type_individual boolean,
    expanded_access_type_intermediate boolean,
    expanded_access_type_treatment boolean,
    has_dmc boolean,
    is_fda_regulated_drug boolean,
    is_fda_regulated_device boolean,
    is_unapproved_device boolean,
    is_ppsd boolean,
    is_us_export boolean,
    biospec_retention character varying,
    biospec_description text,
    ipd_time_frame character varying,
    ipd_access_criteria character varying,
    ipd_url character varying,
    plan_to_share_ipd character varying,
    plan_to_share_ipd_description character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    source_class character varying,
    delayed_posting boolean,
    expanded_access_nctid character varying,
    expanded_access_status_for_nctid character varying,
    fdaaa801_violation boolean,
    baseline_type_units_analyzed character varying,
    patient_registry boolean
);


--
-- Name: study_records; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_records (
    id bigint NOT NULL,
    nct_id character varying,
    type character varying,
    content json,
    sha character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: study_records_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_records_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_records_id_seq OWNED BY ctgov.study_records.id;


--
-- Name: study_references; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_references (
    id integer NOT NULL,
    nct_id character varying,
    pmid character varying,
    reference_type character varying,
    citation text
);


--
-- Name: study_references_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_references_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_references_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_references_id_seq OWNED BY ctgov.study_references.id;


--
-- Name: study_searches; Type: TABLE; Schema: ctgov; Owner: -
--

CREATE TABLE ctgov.study_searches (
    id integer NOT NULL,
    save_tsv boolean DEFAULT false NOT NULL,
    query character varying NOT NULL,
    "grouping" character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    beta_api boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    active boolean
);


--
-- Name: study_searches_id_seq; Type: SEQUENCE; Schema: ctgov; Owner: -
--

CREATE SEQUENCE ctgov.study_searches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_searches_id_seq; Type: SEQUENCE OWNED BY; Schema: ctgov; Owner: -
--

ALTER SEQUENCE ctgov.study_searches_id_seq OWNED BY ctgov.study_searches.id;


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
    db_activity bigint,
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: active_storage_attachments; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.active_storage_attachments_id_seq OWNED BY support.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.active_storage_blobs_id_seq OWNED BY support.active_storage_blobs.id;


--
-- Name: background_jobs; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.background_jobs (
    id bigint NOT NULL,
    user_id integer,
    status character varying,
    completed_at timestamp without time zone,
    logs character varying,
    type character varying,
    data json,
    url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_error_message character varying
);


--
-- Name: background_jobs_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.background_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: background_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.background_jobs_id_seq OWNED BY support.background_jobs.id;


--
-- Name: ctgov_mapping; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_mapping (
    id bigint NOT NULL,
    table_name character varying,
    field_name character varying,
    api_path character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_mapping_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_mapping_id_seq OWNED BY support.ctgov_mapping.id;


--
-- Name: ctgov_mapping_snapshots; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_mapping_snapshots (
    id bigint NOT NULL,
    snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_mapping_snapshots_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_mapping_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_mapping_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_mapping_snapshots_id_seq OWNED BY support.ctgov_mapping_snapshots.id;


--
-- Name: ctgov_metadata; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_metadata (
    id bigint NOT NULL,
    name character varying,
    data_type character varying,
    piece character varying,
    source_type character varying,
    synonyms boolean,
    label character varying,
    url character varying,
    path character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_metadata_id_seq OWNED BY support.ctgov_metadata.id;


--
-- Name: ctgov_metadata_snapshots; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_metadata_snapshots (
    id bigint NOT NULL,
    api_version character varying NOT NULL,
    snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_metadata_snapshots_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_metadata_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_metadata_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_metadata_snapshots_id_seq OWNED BY support.ctgov_metadata_snapshots.id;


--
-- Name: ctgov_schema; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_schema (
    id bigint NOT NULL,
    table_name character varying NOT NULL,
    column_name character varying NOT NULL,
    data_type character varying NOT NULL,
    nullable boolean NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_schema_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_schema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_schema_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_schema_id_seq OWNED BY support.ctgov_schema.id;


--
-- Name: ctgov_schema_snapshots; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.ctgov_schema_snapshots (
    id bigint NOT NULL,
    schema_name character varying NOT NULL,
    snapshot jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ctgov_schema_snapshots_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.ctgov_schema_snapshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ctgov_schema_snapshots_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.ctgov_schema_snapshots_id_seq OWNED BY support.ctgov_schema_snapshots.id;


--
-- Name: file_records; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.file_records (
    id bigint NOT NULL,
    filename character varying,
    file_size bigint,
    file_type character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    url character varying,
    load_event_id bigint
);


--
-- Name: file_records_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.file_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: file_records_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.file_records_id_seq OWNED BY support.file_records.id;


--
-- Name: load_events; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.load_events (
    id integer NOT NULL,
    event_type character varying,
    status character varying,
    description text,
    problems text,
    should_add integer,
    should_change integer,
    processed integer,
    load_time character varying,
    completed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: load_events_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.load_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_events_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.load_events_id_seq OWNED BY support.load_events.id;


--
-- Name: load_issues; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.load_issues (
    id bigint NOT NULL,
    load_event_id bigint,
    nct_id character varying,
    message character varying
);


--
-- Name: load_issues_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.load_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: load_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.load_issues_id_seq OWNED BY support.load_issues.id;


--
-- Name: sanity_checks; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.sanity_checks (
    id integer NOT NULL,
    table_name character varying,
    nct_id character varying,
    column_name character varying,
    check_type character varying,
    row_count integer,
    description text,
    most_current boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    load_event_id bigint
);


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.sanity_checks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sanity_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.sanity_checks_id_seq OWNED BY support.sanity_checks.id;


--
-- Name: settings; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.settings (
    id bigint NOT NULL,
    key character varying NOT NULL,
    value text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.settings_id_seq OWNED BY support.settings.id;


--
-- Name: study_json_records; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.study_json_records (
    id integer NOT NULL,
    nct_id character varying NOT NULL,
    content jsonb NOT NULL,
    saved_study_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    download_date character varying,
    version character varying DEFAULT '1'::character varying
);


--
-- Name: study_json_records_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.study_json_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_json_records_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.study_json_records_id_seq OWNED BY support.study_json_records.id;


--
-- Name: study_statistics_comparisons; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.study_statistics_comparisons (
    id bigint NOT NULL,
    ctgov_selector character varying,
    "table" character varying,
    "column" character varying,
    condition character varying,
    instances_query character varying,
    unique_query character varying
);


--
-- Name: study_statistics_comparisons_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.study_statistics_comparisons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_statistics_comparisons_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.study_statistics_comparisons_id_seq OWNED BY support.study_statistics_comparisons.id;


--
-- Name: study_xml_records; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.study_xml_records (
    id integer NOT NULL,
    nct_id character varying,
    content xml,
    created_study_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.study_xml_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_xml_records_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.study_xml_records_id_seq OWNED BY support.study_xml_records.id;


--
-- Name: verifiers; Type: TABLE; Schema: support; Owner: -
--

CREATE TABLE support.verifiers (
    id bigint NOT NULL,
    differences json DEFAULT '[]'::json NOT NULL,
    last_run timestamp without time zone,
    source json,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    load_event_id integer
);


--
-- Name: verifiers_id_seq; Type: SEQUENCE; Schema: support; Owner: -
--

CREATE SEQUENCE support.verifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: verifiers_id_seq; Type: SEQUENCE OWNED BY; Schema: support; Owner: -
--

ALTER SEQUENCE support.verifiers_id_seq OWNED BY support.verifiers.id;


--
-- Name: attachments id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.attachments ALTER COLUMN id SET DEFAULT nextval('ctgov.attachments_id_seq'::regclass);


--
-- Name: baseline_counts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_counts ALTER COLUMN id SET DEFAULT nextval('ctgov.baseline_counts_id_seq'::regclass);


--
-- Name: baseline_measurements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov.baseline_measurements_id_seq'::regclass);


--
-- Name: brief_summaries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.brief_summaries ALTER COLUMN id SET DEFAULT nextval('ctgov.brief_summaries_id_seq'::regclass);


--
-- Name: browse_conditions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_conditions ALTER COLUMN id SET DEFAULT nextval('ctgov.browse_conditions_id_seq'::regclass);


--
-- Name: browse_interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.browse_interventions_id_seq'::regclass);


--
-- Name: calculated_values id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.calculated_values ALTER COLUMN id SET DEFAULT nextval('ctgov.calculated_values_id_seq'::regclass);


--
-- Name: central_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.central_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.central_contacts_id_seq'::regclass);


--
-- Name: conditions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.conditions ALTER COLUMN id SET DEFAULT nextval('ctgov.conditions_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.countries ALTER COLUMN id SET DEFAULT nextval('ctgov.countries_id_seq'::regclass);


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
-- Name: design_group_interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.design_group_interventions_id_seq'::regclass);


--
-- Name: design_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.design_groups_id_seq'::regclass);


--
-- Name: design_outcomes id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov.design_outcomes_id_seq'::regclass);


--
-- Name: designs id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.designs ALTER COLUMN id SET DEFAULT nextval('ctgov.designs_id_seq'::regclass);


--
-- Name: detailed_descriptions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.detailed_descriptions ALTER COLUMN id SET DEFAULT nextval('ctgov.detailed_descriptions_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.documents ALTER COLUMN id SET DEFAULT nextval('ctgov.documents_id_seq'::regclass);


--
-- Name: drop_withdrawals id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.drop_withdrawals ALTER COLUMN id SET DEFAULT nextval('ctgov.drop_withdrawals_id_seq'::regclass);


--
-- Name: eligibilities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.eligibilities ALTER COLUMN id SET DEFAULT nextval('ctgov.eligibilities_id_seq'::regclass);


--
-- Name: enumerations id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations ALTER COLUMN id SET DEFAULT nextval('ctgov.enumerations_id_seq'::regclass);


--
-- Name: facilities id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facilities ALTER COLUMN id SET DEFAULT nextval('ctgov.facilities_id_seq'::regclass);


--
-- Name: facility_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.facility_contacts_id_seq'::regclass);


--
-- Name: facility_investigators id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_investigators ALTER COLUMN id SET DEFAULT nextval('ctgov.facility_investigators_id_seq'::regclass);


--
-- Name: faqs id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.faqs ALTER COLUMN id SET DEFAULT nextval('ctgov.faqs_id_seq'::regclass);


--
-- Name: file_downloads id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.file_downloads ALTER COLUMN id SET DEFAULT nextval('ctgov.file_downloads_id_seq'::regclass);


--
-- Name: health_checks id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks ALTER COLUMN id SET DEFAULT nextval('ctgov.health_checks_id_seq'::regclass);


--
-- Name: id_information id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.id_information ALTER COLUMN id SET DEFAULT nextval('ctgov.id_information_id_seq'::regclass);


--
-- Name: intervention_other_names id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.intervention_other_names ALTER COLUMN id SET DEFAULT nextval('ctgov.intervention_other_names_id_seq'::regclass);


--
-- Name: interventions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.interventions ALTER COLUMN id SET DEFAULT nextval('ctgov.interventions_id_seq'::regclass);


--
-- Name: ipd_information_types id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.ipd_information_types ALTER COLUMN id SET DEFAULT nextval('ctgov.ipd_information_types_id_seq'::regclass);


--
-- Name: keywords id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.keywords ALTER COLUMN id SET DEFAULT nextval('ctgov.keywords_id_seq'::regclass);


--
-- Name: links id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.links ALTER COLUMN id SET DEFAULT nextval('ctgov.links_id_seq'::regclass);


--
-- Name: mesh_headings id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_headings ALTER COLUMN id SET DEFAULT nextval('ctgov.mesh_headings_id_seq'::regclass);


--
-- Name: mesh_terms id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_terms ALTER COLUMN id SET DEFAULT nextval('ctgov.mesh_terms_id_seq'::regclass);


--
-- Name: milestones id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.milestones ALTER COLUMN id SET DEFAULT nextval('ctgov.milestones_id_seq'::regclass);


--
-- Name: notices id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.notices ALTER COLUMN id SET DEFAULT nextval('ctgov.notices_id_seq'::regclass);


--
-- Name: outcome_analyses id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analyses ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_analyses_id_seq'::regclass);


--
-- Name: outcome_analysis_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_analysis_groups_id_seq'::regclass);


--
-- Name: outcome_counts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_counts_id_seq'::regclass);


--
-- Name: outcome_measurements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements ALTER COLUMN id SET DEFAULT nextval('ctgov.outcome_measurements_id_seq'::regclass);


--
-- Name: outcomes id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcomes ALTER COLUMN id SET DEFAULT nextval('ctgov.outcomes_id_seq'::regclass);


--
-- Name: overall_officials id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.overall_officials ALTER COLUMN id SET DEFAULT nextval('ctgov.overall_officials_id_seq'::regclass);


--
-- Name: participant_flows id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.participant_flows ALTER COLUMN id SET DEFAULT nextval('ctgov.participant_flows_id_seq'::regclass);


--
-- Name: pending_results id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.pending_results ALTER COLUMN id SET DEFAULT nextval('ctgov.pending_results_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.projects ALTER COLUMN id SET DEFAULT nextval('ctgov.projects_id_seq'::regclass);


--
-- Name: provided_documents id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.provided_documents ALTER COLUMN id SET DEFAULT nextval('ctgov.provided_documents_id_seq'::regclass);


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
-- Name: reported_event_totals id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_event_totals ALTER COLUMN id SET DEFAULT nextval('ctgov.reported_event_totals_id_seq'::regclass);


--
-- Name: reported_events id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_events ALTER COLUMN id SET DEFAULT nextval('ctgov.reported_events_id_seq'::regclass);


--
-- Name: responsible_parties id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.responsible_parties ALTER COLUMN id SET DEFAULT nextval('ctgov.responsible_parties_id_seq'::regclass);


--
-- Name: result_agreements id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_agreements ALTER COLUMN id SET DEFAULT nextval('ctgov.result_agreements_id_seq'::regclass);


--
-- Name: result_contacts id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_contacts ALTER COLUMN id SET DEFAULT nextval('ctgov.result_contacts_id_seq'::regclass);


--
-- Name: result_groups id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_groups ALTER COLUMN id SET DEFAULT nextval('ctgov.result_groups_id_seq'::regclass);


--
-- Name: retractions id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.retractions ALTER COLUMN id SET DEFAULT nextval('ctgov.retractions_id_seq'::regclass);


--
-- Name: saved_queries id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries ALTER COLUMN id SET DEFAULT nextval('ctgov.saved_queries_id_seq'::regclass);


--
-- Name: search_results id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_results ALTER COLUMN id SET DEFAULT nextval('ctgov.search_results_id_seq'::regclass);


--
-- Name: search_term_results id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_term_results ALTER COLUMN id SET DEFAULT nextval('ctgov.search_term_results_id_seq'::regclass);


--
-- Name: search_terms id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_terms ALTER COLUMN id SET DEFAULT nextval('ctgov.search_terms_id_seq'::regclass);


--
-- Name: sponsors id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sponsors ALTER COLUMN id SET DEFAULT nextval('ctgov.sponsors_id_seq'::regclass);


--
-- Name: study_records id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_records ALTER COLUMN id SET DEFAULT nextval('ctgov.study_records_id_seq'::regclass);


--
-- Name: study_references id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_references ALTER COLUMN id SET DEFAULT nextval('ctgov.study_references_id_seq'::regclass);


--
-- Name: study_searches id; Type: DEFAULT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_searches ALTER COLUMN id SET DEFAULT nextval('ctgov.study_searches_id_seq'::regclass);


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
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('support.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('support.active_storage_blobs_id_seq'::regclass);


--
-- Name: background_jobs id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.background_jobs ALTER COLUMN id SET DEFAULT nextval('support.background_jobs_id_seq'::regclass);


--
-- Name: ctgov_mapping id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_mapping ALTER COLUMN id SET DEFAULT nextval('support.ctgov_mapping_id_seq'::regclass);


--
-- Name: ctgov_mapping_snapshots id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_mapping_snapshots ALTER COLUMN id SET DEFAULT nextval('support.ctgov_mapping_snapshots_id_seq'::regclass);


--
-- Name: ctgov_metadata id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_metadata ALTER COLUMN id SET DEFAULT nextval('support.ctgov_metadata_id_seq'::regclass);


--
-- Name: ctgov_metadata_snapshots id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_metadata_snapshots ALTER COLUMN id SET DEFAULT nextval('support.ctgov_metadata_snapshots_id_seq'::regclass);


--
-- Name: ctgov_schema id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_schema ALTER COLUMN id SET DEFAULT nextval('support.ctgov_schema_id_seq'::regclass);


--
-- Name: ctgov_schema_snapshots id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_schema_snapshots ALTER COLUMN id SET DEFAULT nextval('support.ctgov_schema_snapshots_id_seq'::regclass);


--
-- Name: file_records id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.file_records ALTER COLUMN id SET DEFAULT nextval('support.file_records_id_seq'::regclass);


--
-- Name: load_events id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.load_events ALTER COLUMN id SET DEFAULT nextval('support.load_events_id_seq'::regclass);


--
-- Name: load_issues id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.load_issues ALTER COLUMN id SET DEFAULT nextval('support.load_issues_id_seq'::regclass);


--
-- Name: sanity_checks id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.sanity_checks ALTER COLUMN id SET DEFAULT nextval('support.sanity_checks_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.settings ALTER COLUMN id SET DEFAULT nextval('support.settings_id_seq'::regclass);


--
-- Name: study_json_records id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_json_records ALTER COLUMN id SET DEFAULT nextval('support.study_json_records_id_seq'::regclass);


--
-- Name: study_statistics_comparisons id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_statistics_comparisons ALTER COLUMN id SET DEFAULT nextval('support.study_statistics_comparisons_id_seq'::regclass);


--
-- Name: study_xml_records id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_xml_records ALTER COLUMN id SET DEFAULT nextval('support.study_xml_records_id_seq'::regclass);


--
-- Name: verifiers id; Type: DEFAULT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.verifiers ALTER COLUMN id SET DEFAULT nextval('support.verifiers_id_seq'::regclass);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: baseline_counts baseline_counts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_counts
    ADD CONSTRAINT baseline_counts_pkey PRIMARY KEY (id);


--
-- Name: baseline_measurements baseline_measurements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.baseline_measurements
    ADD CONSTRAINT baseline_measurements_pkey PRIMARY KEY (id);


--
-- Name: brief_summaries brief_summaries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.brief_summaries
    ADD CONSTRAINT brief_summaries_pkey PRIMARY KEY (id);


--
-- Name: browse_conditions browse_conditions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_conditions
    ADD CONSTRAINT browse_conditions_pkey PRIMARY KEY (id);


--
-- Name: browse_interventions browse_interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.browse_interventions
    ADD CONSTRAINT browse_interventions_pkey PRIMARY KEY (id);


--
-- Name: calculated_values calculated_values_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.calculated_values
    ADD CONSTRAINT calculated_values_pkey PRIMARY KEY (id);


--
-- Name: central_contacts central_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.central_contacts
    ADD CONSTRAINT central_contacts_pkey PRIMARY KEY (id);


--
-- Name: conditions conditions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.conditions
    ADD CONSTRAINT conditions_pkey PRIMARY KEY (id);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


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
-- Name: design_group_interventions design_group_interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_group_interventions
    ADD CONSTRAINT design_group_interventions_pkey PRIMARY KEY (id);


--
-- Name: design_groups design_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_groups
    ADD CONSTRAINT design_groups_pkey PRIMARY KEY (id);


--
-- Name: design_outcomes design_outcomes_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.design_outcomes
    ADD CONSTRAINT design_outcomes_pkey PRIMARY KEY (id);


--
-- Name: designs designs_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.designs
    ADD CONSTRAINT designs_pkey PRIMARY KEY (id);


--
-- Name: detailed_descriptions detailed_descriptions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.detailed_descriptions
    ADD CONSTRAINT detailed_descriptions_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: drop_withdrawals drop_withdrawals_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.drop_withdrawals
    ADD CONSTRAINT drop_withdrawals_pkey PRIMARY KEY (id);


--
-- Name: eligibilities eligibilities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.eligibilities
    ADD CONSTRAINT eligibilities_pkey PRIMARY KEY (id);


--
-- Name: enumerations enumerations_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.enumerations
    ADD CONSTRAINT enumerations_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_contacts facility_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_contacts
    ADD CONSTRAINT facility_contacts_pkey PRIMARY KEY (id);


--
-- Name: facility_investigators facility_investigators_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.facility_investigators
    ADD CONSTRAINT facility_investigators_pkey PRIMARY KEY (id);


--
-- Name: faqs faqs_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.faqs
    ADD CONSTRAINT faqs_pkey PRIMARY KEY (id);


--
-- Name: file_downloads file_downloads_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.file_downloads
    ADD CONSTRAINT file_downloads_pkey PRIMARY KEY (id);


--
-- Name: health_checks health_checks_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.health_checks
    ADD CONSTRAINT health_checks_pkey PRIMARY KEY (id);


--
-- Name: id_information id_information_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.id_information
    ADD CONSTRAINT id_information_pkey PRIMARY KEY (id);


--
-- Name: intervention_other_names intervention_other_names_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.intervention_other_names
    ADD CONSTRAINT intervention_other_names_pkey PRIMARY KEY (id);


--
-- Name: interventions interventions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.interventions
    ADD CONSTRAINT interventions_pkey PRIMARY KEY (id);


--
-- Name: ipd_information_types ipd_information_types_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.ipd_information_types
    ADD CONSTRAINT ipd_information_types_pkey PRIMARY KEY (id);


--
-- Name: keywords keywords_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (id);


--
-- Name: links links_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.links
    ADD CONSTRAINT links_pkey PRIMARY KEY (id);


--
-- Name: mesh_headings mesh_headings_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_headings
    ADD CONSTRAINT mesh_headings_pkey PRIMARY KEY (id);


--
-- Name: mesh_terms mesh_terms_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.mesh_terms
    ADD CONSTRAINT mesh_terms_pkey PRIMARY KEY (id);


--
-- Name: milestones milestones_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);


--
-- Name: notices notices_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.notices
    ADD CONSTRAINT notices_pkey PRIMARY KEY (id);


--
-- Name: outcome_analyses outcome_analyses_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analyses
    ADD CONSTRAINT outcome_analyses_pkey PRIMARY KEY (id);


--
-- Name: outcome_analysis_groups outcome_analysis_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_analysis_groups
    ADD CONSTRAINT outcome_analysis_groups_pkey PRIMARY KEY (id);


--
-- Name: outcome_counts outcome_counts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_counts
    ADD CONSTRAINT outcome_counts_pkey PRIMARY KEY (id);


--
-- Name: outcome_measurements outcome_measurements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcome_measurements
    ADD CONSTRAINT outcome_measurements_pkey PRIMARY KEY (id);


--
-- Name: outcomes outcomes_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.outcomes
    ADD CONSTRAINT outcomes_pkey PRIMARY KEY (id);


--
-- Name: overall_officials overall_officials_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.overall_officials
    ADD CONSTRAINT overall_officials_pkey PRIMARY KEY (id);


--
-- Name: participant_flows participant_flows_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.participant_flows
    ADD CONSTRAINT participant_flows_pkey PRIMARY KEY (id);


--
-- Name: pending_results pending_results_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.pending_results
    ADD CONSTRAINT pending_results_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: provided_documents provided_documents_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.provided_documents
    ADD CONSTRAINT provided_documents_pkey PRIMARY KEY (id);


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
-- Name: reported_event_totals reported_event_totals_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_event_totals
    ADD CONSTRAINT reported_event_totals_pkey PRIMARY KEY (id);


--
-- Name: reported_events reported_events_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.reported_events
    ADD CONSTRAINT reported_events_pkey PRIMARY KEY (id);


--
-- Name: responsible_parties responsible_parties_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.responsible_parties
    ADD CONSTRAINT responsible_parties_pkey PRIMARY KEY (id);


--
-- Name: result_agreements result_agreements_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_agreements
    ADD CONSTRAINT result_agreements_pkey PRIMARY KEY (id);


--
-- Name: result_contacts result_contacts_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_contacts
    ADD CONSTRAINT result_contacts_pkey PRIMARY KEY (id);


--
-- Name: result_groups result_groups_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.result_groups
    ADD CONSTRAINT result_groups_pkey PRIMARY KEY (id);


--
-- Name: retractions retractions_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.retractions
    ADD CONSTRAINT retractions_pkey PRIMARY KEY (id);


--
-- Name: saved_queries saved_queries_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries
    ADD CONSTRAINT saved_queries_pkey PRIMARY KEY (id);


--
-- Name: search_results search_results_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_results
    ADD CONSTRAINT search_results_pkey PRIMARY KEY (id);


--
-- Name: search_term_results search_term_results_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_term_results
    ADD CONSTRAINT search_term_results_pkey PRIMARY KEY (id);


--
-- Name: search_terms search_terms_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_terms
    ADD CONSTRAINT search_terms_pkey PRIMARY KEY (id);


--
-- Name: sponsors sponsors_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.sponsors
    ADD CONSTRAINT sponsors_pkey PRIMARY KEY (id);


--
-- Name: study_records study_records_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_records
    ADD CONSTRAINT study_records_pkey PRIMARY KEY (id);


--
-- Name: study_references study_references_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_references
    ADD CONSTRAINT study_references_pkey PRIMARY KEY (id);


--
-- Name: study_searches study_searches_pkey; Type: CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.study_searches
    ADD CONSTRAINT study_searches_pkey PRIMARY KEY (id);


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
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: background_jobs background_jobs_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.background_jobs
    ADD CONSTRAINT background_jobs_pkey PRIMARY KEY (id);


--
-- Name: ctgov_mapping ctgov_mapping_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_mapping
    ADD CONSTRAINT ctgov_mapping_pkey PRIMARY KEY (id);


--
-- Name: ctgov_mapping_snapshots ctgov_mapping_snapshots_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_mapping_snapshots
    ADD CONSTRAINT ctgov_mapping_snapshots_pkey PRIMARY KEY (id);


--
-- Name: ctgov_metadata ctgov_metadata_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_metadata
    ADD CONSTRAINT ctgov_metadata_pkey PRIMARY KEY (id);


--
-- Name: ctgov_metadata_snapshots ctgov_metadata_snapshots_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_metadata_snapshots
    ADD CONSTRAINT ctgov_metadata_snapshots_pkey PRIMARY KEY (id);


--
-- Name: ctgov_schema ctgov_schema_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_schema
    ADD CONSTRAINT ctgov_schema_pkey PRIMARY KEY (id);


--
-- Name: ctgov_schema_snapshots ctgov_schema_snapshots_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.ctgov_schema_snapshots
    ADD CONSTRAINT ctgov_schema_snapshots_pkey PRIMARY KEY (id);


--
-- Name: file_records file_records_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.file_records
    ADD CONSTRAINT file_records_pkey PRIMARY KEY (id);


--
-- Name: load_events load_events_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.load_events
    ADD CONSTRAINT load_events_pkey PRIMARY KEY (id);


--
-- Name: load_issues load_issues_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.load_issues
    ADD CONSTRAINT load_issues_pkey PRIMARY KEY (id);


--
-- Name: sanity_checks sanity_checks_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.sanity_checks
    ADD CONSTRAINT sanity_checks_pkey PRIMARY KEY (id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: study_json_records study_json_records_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_json_records
    ADD CONSTRAINT study_json_records_pkey PRIMARY KEY (id);


--
-- Name: study_statistics_comparisons study_statistics_comparisons_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_statistics_comparisons
    ADD CONSTRAINT study_statistics_comparisons_pkey PRIMARY KEY (id);


--
-- Name: study_xml_records study_xml_records_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.study_xml_records
    ADD CONSTRAINT study_xml_records_pkey PRIMARY KEY (id);


--
-- Name: verifiers verifiers_pkey; Type: CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.verifiers
    ADD CONSTRAINT verifiers_pkey PRIMARY KEY (id);


--
-- Name: index_baseline_measurements_on_category; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_measurements_on_category ON ctgov.baseline_measurements USING btree (category);


--
-- Name: index_baseline_measurements_on_classification; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_measurements_on_classification ON ctgov.baseline_measurements USING btree (classification);


--
-- Name: index_baseline_measurements_on_dispersion_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_measurements_on_dispersion_type ON ctgov.baseline_measurements USING btree (dispersion_type);


--
-- Name: index_baseline_measurements_on_param_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_baseline_measurements_on_param_type ON ctgov.baseline_measurements USING btree (param_type);


--
-- Name: index_browse_conditions_on_downcase_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_conditions_on_downcase_mesh_term ON ctgov.browse_conditions USING btree (downcase_mesh_term);


--
-- Name: index_browse_conditions_on_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_conditions_on_mesh_term ON ctgov.browse_conditions USING btree (mesh_term);


--
-- Name: index_browse_conditions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_conditions_on_nct_id ON ctgov.browse_conditions USING btree (nct_id);


--
-- Name: index_browse_interventions_on_downcase_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_interventions_on_downcase_mesh_term ON ctgov.browse_interventions USING btree (downcase_mesh_term);


--
-- Name: index_browse_interventions_on_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_interventions_on_mesh_term ON ctgov.browse_interventions USING btree (mesh_term);


--
-- Name: index_browse_interventions_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_browse_interventions_on_nct_id ON ctgov.browse_interventions USING btree (nct_id);


--
-- Name: index_calculated_values_on_actual_duration; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_calculated_values_on_actual_duration ON ctgov.calculated_values USING btree (actual_duration);


--
-- Name: index_calculated_values_on_months_to_report_results; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_calculated_values_on_months_to_report_results ON ctgov.calculated_values USING btree (months_to_report_results);


--
-- Name: index_calculated_values_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_calculated_values_on_nct_id ON ctgov.calculated_values USING btree (nct_id);


--
-- Name: index_calculated_values_on_number_of_facilities; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_calculated_values_on_number_of_facilities ON ctgov.calculated_values USING btree (number_of_facilities);


--
-- Name: index_central_contacts_on_contact_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_central_contacts_on_contact_type ON ctgov.central_contacts USING btree (contact_type);


--
-- Name: index_conditions_on_downcase_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_conditions_on_downcase_name ON ctgov.conditions USING btree (downcase_name);


--
-- Name: index_conditions_on_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_conditions_on_name ON ctgov.conditions USING btree (name);


--
-- Name: index_ctgov.search_term_results_on_search_term_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX "index_ctgov.search_term_results_on_search_term_id" ON ctgov.search_term_results USING btree (search_term_id);


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
-- Name: index_ctgov_search_term_results_on_nct_id_and_search_term_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_search_term_results_on_nct_id_and_search_term_id ON ctgov.search_term_results USING btree (nct_id, search_term_id);


--
-- Name: index_ctgov_search_terms_on_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_search_terms_on_term ON ctgov.search_terms USING btree (term);


--
-- Name: index_design_group_interventions_on_design_group_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_group_interventions_on_design_group_id ON ctgov.design_group_interventions USING btree (design_group_id);


--
-- Name: index_design_group_interventions_on_intervention_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_group_interventions_on_intervention_id ON ctgov.design_group_interventions USING btree (intervention_id);


--
-- Name: index_design_groups_on_group_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_groups_on_group_type ON ctgov.design_groups USING btree (group_type);


--
-- Name: index_design_outcomes_on_measure; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_outcomes_on_measure ON ctgov.design_outcomes USING btree (measure);


--
-- Name: index_design_outcomes_on_outcome_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_design_outcomes_on_outcome_type ON ctgov.design_outcomes USING btree (outcome_type);


--
-- Name: index_designs_on_caregiver_masked; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_designs_on_caregiver_masked ON ctgov.designs USING btree (caregiver_masked);


--
-- Name: index_designs_on_investigator_masked; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_designs_on_investigator_masked ON ctgov.designs USING btree (investigator_masked);


--
-- Name: index_designs_on_masking; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_designs_on_masking ON ctgov.designs USING btree (masking);


--
-- Name: index_designs_on_outcomes_assessor_masked; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_designs_on_outcomes_assessor_masked ON ctgov.designs USING btree (outcomes_assessor_masked);


--
-- Name: index_designs_on_subject_masked; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_designs_on_subject_masked ON ctgov.designs USING btree (subject_masked);


--
-- Name: index_documents_on_document_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_documents_on_document_id ON ctgov.documents USING btree (document_id);


--
-- Name: index_documents_on_document_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_documents_on_document_type ON ctgov.documents USING btree (document_type);


--
-- Name: index_drop_withdrawals_on_period; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_drop_withdrawals_on_period ON ctgov.drop_withdrawals USING btree (period);


--
-- Name: index_eligibilities_on_gender; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_eligibilities_on_gender ON ctgov.eligibilities USING btree (gender);


--
-- Name: index_eligibilities_on_healthy_volunteers; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_eligibilities_on_healthy_volunteers ON ctgov.eligibilities USING btree (healthy_volunteers);


--
-- Name: index_eligibilities_on_maximum_age; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_eligibilities_on_maximum_age ON ctgov.eligibilities USING btree (maximum_age);


--
-- Name: index_eligibilities_on_minimum_age; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_eligibilities_on_minimum_age ON ctgov.eligibilities USING btree (minimum_age);


--
-- Name: index_facilities_on_city; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_city ON ctgov.facilities USING btree (city);


--
-- Name: index_facilities_on_country; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_country ON ctgov.facilities USING btree (country);


--
-- Name: index_facilities_on_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_name ON ctgov.facilities USING btree (name);


--
-- Name: index_facilities_on_state; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_state ON ctgov.facilities USING btree (state);


--
-- Name: index_facilities_on_status; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facilities_on_status ON ctgov.facilities USING btree (status);


--
-- Name: index_facility_contacts_on_contact_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_facility_contacts_on_contact_type ON ctgov.facility_contacts USING btree (contact_type);


--
-- Name: index_id_information_on_id_source; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_id_information_on_id_source ON ctgov.id_information USING btree (id_source);


--
-- Name: index_interventions_on_intervention_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_interventions_on_intervention_type ON ctgov.interventions USING btree (intervention_type);


--
-- Name: index_keywords_on_downcase_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_keywords_on_downcase_name ON ctgov.keywords USING btree (downcase_name);


--
-- Name: index_keywords_on_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_keywords_on_name ON ctgov.keywords USING btree (name);


--
-- Name: index_mesh_headings_on_qualifier; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_headings_on_qualifier ON ctgov.mesh_headings USING btree (qualifier);


--
-- Name: index_mesh_headings_on_qualifier_heading_subcategory; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_mesh_headings_on_qualifier_heading_subcategory ON ctgov.mesh_headings USING btree (qualifier, heading, subcategory);


--
-- Name: index_mesh_terms_on_description; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_description ON ctgov.mesh_terms USING btree (description);


--
-- Name: index_mesh_terms_on_downcase_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_downcase_mesh_term ON ctgov.mesh_terms USING btree (downcase_mesh_term);


--
-- Name: index_mesh_terms_on_mesh_term; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_mesh_term ON ctgov.mesh_terms USING btree (mesh_term);


--
-- Name: index_mesh_terms_on_qualifier; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_mesh_terms_on_qualifier ON ctgov.mesh_terms USING btree (qualifier);


--
-- Name: index_milestones_on_period; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_milestones_on_period ON ctgov.milestones USING btree (period);


--
-- Name: index_outcome_analyses_on_dispersion_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_analyses_on_dispersion_type ON ctgov.outcome_analyses USING btree (dispersion_type);


--
-- Name: index_outcome_analyses_on_param_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_analyses_on_param_type ON ctgov.outcome_analyses USING btree (param_type);


--
-- Name: index_outcome_measurements_on_category; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_measurements_on_category ON ctgov.outcome_measurements USING btree (category);


--
-- Name: index_outcome_measurements_on_classification; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_measurements_on_classification ON ctgov.outcome_measurements USING btree (classification);


--
-- Name: index_outcome_measurements_on_dispersion_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcome_measurements_on_dispersion_type ON ctgov.outcome_measurements USING btree (dispersion_type);


--
-- Name: index_outcomes_on_dispersion_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcomes_on_dispersion_type ON ctgov.outcomes USING btree (dispersion_type);


--
-- Name: index_outcomes_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcomes_on_nct_id ON ctgov.outcomes USING btree (nct_id);


--
-- Name: index_outcomes_on_param_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_outcomes_on_param_type ON ctgov.outcomes USING btree (param_type);


--
-- Name: index_overall_officials_on_affiliation; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_overall_officials_on_affiliation ON ctgov.overall_officials USING btree (affiliation);


--
-- Name: index_overall_officials_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_overall_officials_on_nct_id ON ctgov.overall_officials USING btree (nct_id);


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
-- Name: index_reported_events_on_event_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_reported_events_on_event_type ON ctgov.reported_events USING btree (event_type);


--
-- Name: index_reported_events_on_subjects_affected; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_reported_events_on_subjects_affected ON ctgov.reported_events USING btree (subjects_affected);


--
-- Name: index_responsible_parties_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_responsible_parties_on_nct_id ON ctgov.responsible_parties USING btree (nct_id);


--
-- Name: index_responsible_parties_on_organization; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_responsible_parties_on_organization ON ctgov.responsible_parties USING btree (organization);


--
-- Name: index_responsible_parties_on_responsible_party_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_responsible_parties_on_responsible_party_type ON ctgov.responsible_parties USING btree (responsible_party_type);


--
-- Name: index_result_contacts_on_organization; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_result_contacts_on_organization ON ctgov.result_contacts USING btree (organization);


--
-- Name: index_result_groups_on_result_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_result_groups_on_result_type ON ctgov.result_groups USING btree (result_type);


--
-- Name: index_saved_queries_on_user_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_saved_queries_on_user_id ON ctgov.saved_queries USING btree (user_id);


--
-- Name: index_search_results_on_nct_id_and_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_search_results_on_nct_id_and_name ON ctgov.search_results USING btree (nct_id, name);


--
-- Name: index_search_results_on_nct_id_and_name_and_grouping; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_search_results_on_nct_id_and_name_and_grouping ON ctgov.search_results USING btree (nct_id, name, "grouping");


--
-- Name: index_sponsors_on_agency_class; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sponsors_on_agency_class ON ctgov.sponsors USING btree (agency_class);


--
-- Name: index_sponsors_on_name; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_sponsors_on_name ON ctgov.sponsors USING btree (name);


--
-- Name: index_studies_on_completion_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_completion_date ON ctgov.studies USING btree (completion_date);


--
-- Name: index_studies_on_disposition_first_submitted_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_disposition_first_submitted_date ON ctgov.studies USING btree (disposition_first_submitted_date);


--
-- Name: index_studies_on_enrollment_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_enrollment_type ON ctgov.studies USING btree (enrollment_type);


--
-- Name: index_studies_on_last_known_status; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_last_known_status ON ctgov.studies USING btree (last_known_status);


--
-- Name: index_studies_on_last_update_submitted_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_last_update_submitted_date ON ctgov.studies USING btree (last_update_submitted_date);


--
-- Name: index_studies_on_nct_id; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_studies_on_nct_id ON ctgov.studies USING btree (nct_id);


--
-- Name: index_studies_on_overall_status; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_overall_status ON ctgov.studies USING btree (overall_status);


--
-- Name: index_studies_on_phase; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_phase ON ctgov.studies USING btree (phase);


--
-- Name: index_studies_on_primary_completion_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_primary_completion_date ON ctgov.studies USING btree (primary_completion_date);


--
-- Name: index_studies_on_primary_completion_date_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_primary_completion_date_type ON ctgov.studies USING btree (primary_completion_date_type);


--
-- Name: index_studies_on_results_first_submitted_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_results_first_submitted_date ON ctgov.studies USING btree (results_first_submitted_date);


--
-- Name: index_studies_on_source; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_source ON ctgov.studies USING btree (source);


--
-- Name: index_studies_on_start_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_start_date ON ctgov.studies USING btree (start_date);


--
-- Name: index_studies_on_start_date_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_start_date_type ON ctgov.studies USING btree (start_date_type);


--
-- Name: index_studies_on_study_first_submitted_date; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_study_first_submitted_date ON ctgov.studies USING btree (study_first_submitted_date);


--
-- Name: index_studies_on_study_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_studies_on_study_type ON ctgov.studies USING btree (study_type);


--
-- Name: index_study_records_on_nct_id_and_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_study_records_on_nct_id_and_type ON ctgov.study_records USING btree (nct_id, type);


--
-- Name: index_study_references_on_reference_type; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE INDEX index_study_references_on_reference_type ON ctgov.study_references USING btree (reference_type);


--
-- Name: index_study_searches_on_query_and_grouping; Type: INDEX; Schema: ctgov; Owner: -
--

CREATE UNIQUE INDEX index_study_searches_on_query_and_grouping ON ctgov.study_searches USING btree (query, "grouping");


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON support.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_ctgov_mapping_on_table_field_api_path; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_mapping_on_table_field_api_path ON support.ctgov_mapping USING btree (table_name, field_name, api_path);


--
-- Name: index_ctgov_metadata_on_path; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_metadata_on_path ON support.ctgov_metadata USING btree (path);


--
-- Name: index_ctgov_schema_on_table_and_column; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX index_ctgov_schema_on_table_and_column ON support.ctgov_schema USING btree (table_name, column_name);


--
-- Name: index_file_records_on_load_event_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX index_file_records_on_load_event_id ON support.file_records USING btree (load_event_id);


--
-- Name: index_study_json_records_on_nct_id_and_version; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX index_study_json_records_on_nct_id_and_version ON support.study_json_records USING btree (nct_id, version);


--
-- Name: index_support.active_storage_attachments_on_blob_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.active_storage_attachments_on_blob_id" ON support.active_storage_attachments USING btree (blob_id);


--
-- Name: index_support.active_storage_blobs_on_key; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX "index_support.active_storage_blobs_on_key" ON support.active_storage_blobs USING btree (key);


--
-- Name: index_support.load_events_on_event_type; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.load_events_on_event_type" ON support.load_events USING btree (event_type);


--
-- Name: index_support.load_events_on_status; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.load_events_on_status" ON support.load_events USING btree (status);


--
-- Name: index_support.load_issues_on_load_event_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.load_issues_on_load_event_id" ON support.load_issues USING btree (load_event_id);


--
-- Name: index_support.sanity_checks_on_check_type; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.sanity_checks_on_check_type" ON support.sanity_checks USING btree (check_type);


--
-- Name: index_support.sanity_checks_on_column_name; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.sanity_checks_on_column_name" ON support.sanity_checks USING btree (column_name);


--
-- Name: index_support.sanity_checks_on_load_event_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.sanity_checks_on_load_event_id" ON support.sanity_checks USING btree (load_event_id);


--
-- Name: index_support.sanity_checks_on_nct_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.sanity_checks_on_nct_id" ON support.sanity_checks USING btree (nct_id);


--
-- Name: index_support.sanity_checks_on_table_name; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.sanity_checks_on_table_name" ON support.sanity_checks USING btree (table_name);


--
-- Name: index_support.settings_on_key; Type: INDEX; Schema: support; Owner: -
--

CREATE UNIQUE INDEX "index_support.settings_on_key" ON support.settings USING btree (key);


--
-- Name: index_support.study_xml_records_on_created_study_at; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.study_xml_records_on_created_study_at" ON support.study_xml_records USING btree (created_study_at);


--
-- Name: index_support.study_xml_records_on_nct_id; Type: INDEX; Schema: support; Owner: -
--

CREATE INDEX "index_support.study_xml_records_on_nct_id" ON support.study_xml_records USING btree (nct_id);


--
-- Name: categories category_insert_trigger; Type: TRIGGER; Schema: ctgov; Owner: -
--

CREATE TRIGGER category_insert_trigger INSTEAD OF INSERT ON ctgov.categories FOR EACH ROW EXECUTE FUNCTION ctgov.category_insert_function();


--
-- Name: search_term_results fk_rails_079d8b7607; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.search_term_results
    ADD CONSTRAINT fk_rails_079d8b7607 FOREIGN KEY (search_term_id) REFERENCES ctgov.search_terms(id);


--
-- Name: saved_queries fk_rails_add691a365; Type: FK CONSTRAINT; Schema: ctgov; Owner: -
--

ALTER TABLE ONLY ctgov.saved_queries
    ADD CONSTRAINT fk_rails_add691a365 FOREIGN KEY (user_id) REFERENCES ctgov.users(id);


--
-- Name: active_storage_attachments fk_rails_0276932754; Type: FK CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.active_storage_attachments
    ADD CONSTRAINT fk_rails_0276932754 FOREIGN KEY (blob_id) REFERENCES support.active_storage_blobs(id);


--
-- Name: load_issues fk_rails_1a961417a0; Type: FK CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.load_issues
    ADD CONSTRAINT fk_rails_1a961417a0 FOREIGN KEY (load_event_id) REFERENCES support.load_events(id);


--
-- Name: sanity_checks fk_rails_9d86ec7e91; Type: FK CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.sanity_checks
    ADD CONSTRAINT fk_rails_9d86ec7e91 FOREIGN KEY (load_event_id) REFERENCES support.load_events(id);


--
-- Name: file_records fk_rails_f437ab93ba; Type: FK CONSTRAINT; Schema: support; Owner: -
--

ALTER TABLE ONLY support.file_records
    ADD CONSTRAINT fk_rails_f437ab93ba FOREIGN KEY (load_event_id) REFERENCES support.load_events(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO ctgov,support,public;

INSERT INTO "schema_migrations" (version) VALUES
('20160214191640'),
('20160630191037'),
('20160910000000'),
('20160911000000'),
('20160912000000'),
('20161011000000'),
('20161030000000'),
('20170411000122'),
('20180226142044'),
('20180427144951'),
('20180813174540'),
('20181108174440'),
('20181208174440'),
('20181212000000'),
('20190115184850'),
('20190115204850'),
('20190301204850'),
('20190321174440'),
('20191125205210'),
('20200217214455'),
('20200217220919'),
('20200424180206'),
('20200622225910'),
('20200814211239'),
('20200922153536'),
('20200922175002'),
('20201201210834'),
('20210108195415'),
('20210108200600'),
('20210308235723'),
('20210414222919'),
('20210526192648'),
('20210526192804'),
('20210601063550'),
('20211027133828'),
('20211027220743'),
('20211102194357'),
('20211109190158'),
('20220202152642'),
('20220207182529'),
('20220212033048'),
('20220308030627'),
('20220329173304'),
('20220429175157'),
('20220512025646'),
('20220512030503'),
('20220512030831'),
('20220520124716'),
('20220520133313'),
('20220522072233'),
('20220523123928'),
('20220608211340'),
('20220817000001'),
('20220919155542'),
('20220928162956'),
('20220928175111'),
('20220930181441'),
('20221018210501'),
('20221122213435'),
('20221219165747'),
('20230102193531'),
('20230131123222'),
('20230214200400'),
('20230216205237'),
('20230416235053'),
('20230628231316'),
('20230629000057'),
('20230720150513'),
('20231012015547'),
('20240204045613'),
('20240204055613'),
('20240306012711'),
('20240311192314'),
('20240324222521'),
('20240621132424'),
('20240621142045'),
('20240629204041'),
('20240629205840'),
('20240702011922'),
('20240711213617'),
('20240730222441'),
('20240901191204'),
('20240907190730'),
('20241013030503'),
('20241013041207'),
('20241023025650'),
('20241105161057'),
('20250110023732'),
('20250123022905');


