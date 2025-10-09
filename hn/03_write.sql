{{define "write_parquet_file"}}

insert into function s3('http://localhost:9001/xyz/hn/data/{{.OUTPUT_FILE}}')
select * from buffer_{{.RANGE_START}}_{{.RANGE_END}}
order by {{.ORDER_BY | default "id"}}

{{end}}

{{define "iceberg_commit"}}

select icepq_add('s3://xyz/hn', ['{{.OUTPUT_FILE}}'])

{{end}}

{{define "drop_buffer"}}

drop table buffer_{{.RANGE_START}}_{{.RANGE_END}} sync

{{end}}
