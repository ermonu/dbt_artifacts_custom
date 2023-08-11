{% macro upload_invocations() -%}

    {# Need to remove keys with results that can't be handled properly #}
    {# warn_error_options - returns a python object in 1.5 #}
    {% if 'warn_error_options' in invocation_args_dict %}
        {% if invocation_args_dict.warn_error_options is not string %}
            {% if invocation_args_dict.warn_error_options.include %}
                {% set include_options = invocation_args_dict.warn_error_options.include %}
            {% else %}
                {% set include_options = '' %}
            {% endif %}
            {% if invocation_args_dict.warn_error_options.exclude %}
                {% set exclude_options = invocation_args_dict.warn_error_options.exclude %}
            {% else %}
                {% set exclude_options = '' %}
            {% endif %}
            {% set warn_error_options = {'include': include_options, 'exclude': exclude_options} %}
            {%- do invocation_args_dict.update({'warn_error_options': warn_error_options}) %}
        {% endif %}
    {% endif %}

    {{ return(adapter.dispatch('get_invocations_dml_sql', 'dbt_artifacts')()) }}
{%- endmacro %}

{% macro default__get_invocations_dml_sql() -%}
    {% set invocation_values %}
    select
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(1) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(2) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(3) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(4) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(5) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(6) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(7) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(8) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(9) }},
        {{ adapter.dispatch('column_identifier', 'dbt_artifacts')(10) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(16)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(17)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(18)) }},
        {{ adapter.dispatch('parse_json', 'dbt_artifacts')(adapter.dispatch('column_identifier', 'dbt_artifacts')(19)) }}
    from values
    (
        '{{ invocation_id }}', {# command_invocation_id #}
        '{{ dbt_version }}', {# dbt_version #}
        '{{ project_name }}', {# project_name #}
        '{{ run_started_at }}', {# run_started_at #}
        '{{ flags.WHICH }}', {# dbt_command #}
        '{{ flags.FULL_REFRESH }}', {# full_refresh_flag #}
        '{{ target.profile_name }}', {# target_profile_name #}
        '{{ target.name }}', {# target_name #}
        '{{ target.schema }}', {# target_schema #}
        {{ target.threads }}, {# target_threads #}


        {% if var('env_vars', none) %}
            {% set env_vars_dict = {} %}
            {% for env_variable in var('env_vars') %}
                {% do env_vars_dict.update({env_variable: (env_var(env_variable, '') | replace("'", "''"))}) %}
            {% endfor %}
            '{{ tojson(env_vars_dict) }}', {# env_vars #}
        {% else %}
            null, {# env_vars #}
        {% endif %}

        {% if var('dbt_vars', none) %}
            {% set dbt_vars_dict = {} %}
            {% for dbt_var in var('dbt_vars') %}
                {% do dbt_vars_dict.update({dbt_var: (var(dbt_var, '') | replace("'", "''"))}) %}
            {% endfor %}
            '{{ tojson(dbt_vars_dict) }}', {# dbt_vars #}
        {% else %}
            null, {# dbt_vars #}
        {% endif %}

        '{{ tojson(invocation_args_dict) | replace('\\', '\\\\') }}', {# invocation_args #}

        {% set metadata_env = {} %}
        {% for key, value in dbt_metadata_envs.items() %}
            {% do metadata_env.update({key: (value | replace("'", "''"))}) %}
        {% endfor %}
        '{{ tojson(metadata_env) | replace('\\', '\\\\') }}' {# dbt_custom_envs #}

    )
    {% endset %}
    {{ invocation_values }}

{% endmacro -%}

{% macro bigquery__get_invocations_dml_sql() -%}
    {% set invocation_values %}
        (
        '{{ invocation_id }}', {# command_invocation_id #}
        '{{ dbt_version }}', {# dbt_version #}
        '{{ project_name }}', {# project_name #}
        '{{ run_started_at }}', {# run_started_at #}
        '{{ flags.WHICH }}', {# dbt_command #}
        {{ flags.FULL_REFRESH }}, {# full_refresh_flag #}
        '{{ target.profile_name }}', {# target_profile_name #}
        '{{ target.name }}', {# target_name #}
        '{{ target.schema }}', {# target_schema #}
        {{ target.threads }}, {# target_threads #}


        {% if var('env_vars', none) %}
            {% set env_vars_dict = {} %}
            {% for env_variable in var('env_vars') %}
                {% do env_vars_dict.update({env_variable: (env_var(env_variable, ''))}) %}
            {% endfor %}
            parse_json('''{{ tojson(env_vars_dict) }}'''), {# env_vars #}
        {% else %}
            null, {# env_vars #}
        {% endif %}

        {% if var('dbt_vars', none) %}
            {% set dbt_vars_dict = {} %}
            {% for dbt_var in var('dbt_vars') %}
                {% do dbt_vars_dict.update({dbt_var: (var(dbt_var, ''))}) %}
            {% endfor %}
            parse_json('''{{ tojson(dbt_vars_dict) }}'''), {# dbt_vars #}
        {% else %}
            null, {# dbt_vars #}
        {% endif %}

        {% if invocation_args_dict.vars %}
            {# vars - different format for pre v1.5 (yaml vs list) #}
            {% if invocation_args_dict.vars is string %}
                {# BigQuery does not handle the yaml-string from "--vars" well, when passed to "parse_json". Workaround is to parse the string, and then "tojson" will properly format the dict as a json-object. #}
                {% set parsed_inv_args_vars = fromyaml(invocation_args_dict.vars) %}
                {% do invocation_args_dict.update({'vars': parsed_inv_args_vars}) %}
            {% endif %}
        {% endif %}

        safe.parse_json('''{{ tojson(invocation_args_dict) }}'''), {# invocation_args #}

        {% set metadata_env = {} %}
        {% for key, value in dbt_metadata_envs.items() %}
            {% do metadata_env.update({key: value}) %}
        {% endfor %}
        parse_json('''{{ tojson(metadata_env) | replace('\\', '\\\\') }}''') {# dbt_custom_envs #}

        )
    {% endset %}
    {{ invocation_values }}

{% endmacro -%}
