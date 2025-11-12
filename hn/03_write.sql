{{define "write_parquet_file"}}

insert into function s3('{{ .ENDPOINT }}/{{ .BUCKET }}{{ .PATH }}/data/{{.OUTPUT_FILE}}', '{{ .ACCESS_KEY_ID }}', '{{ .SECRET_ACCESS_KEY }}')
select * from buffer_{{.RANGE_START}}_{{.RANGE_END}}
order by {{.ORDER_BY}}

{{end}}

{{define "iceberg_commit"}}

select icepq_add(
    's3://{{ .BUCKET }}{{ .PATH }}#endpoint={{ .ENDPOINT }}&region={{ .REGION }}&access_key_id={{ .ACCESS_KEY_ID }}&secret_access_key={{ .SECRET_ACCESS_KEY}}&force_path_style={{ .FORCE_PATH_STYLE | default "false" }}',
    ['{{.OUTPUT_FILE}}']
)

{{end}}

{{define "drop_buffer"}}

drop table buffer_{{.RANGE_START}}_{{.RANGE_END}} sync

{{end}}