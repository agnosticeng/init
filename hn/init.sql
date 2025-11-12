{{define "init_start"}}

select
    arrayMax(res.value[].upper)::UInt64 as INIT_START,
    throwIf(res.error::String = 'table does not exist', 'table does not exists', 8888::Int16),
    throwIf(res.error::String <> '', res.error::String),
from (
    select icepq_field_bound_values(
        's3://{{ .BUCKET }}{{ .PATH }}#endpoint={{ .ENDPOINT }}&region={{ .REGION }}&access_key_id={{ .ACCESS_KEY_ID }}&secret_access_key={{ .SECRET_ACCESS_KEY}}&force_path_style={{ .FORCE_PATH_STYLE | default "false" }}',
        'id'
    ) as res
)
settings allow_custom_error_code_in_throwif=true

{{end}}
