# Hacker News Data Pipeline

A real-time data pipeline that fetches Hacker News items and processes them using ClickHouse with Iceberg table format for efficient storage and querying.

## Overview

This pipeline continuously monitors the Hacker News API for new items, fetches them in batches, and stores them in an optimized columnar format. It's built using the AGT (Agnostic) pipeline framework with ClickHouse as the processing engine.

## Architecture

The pipeline consists of several key components:

### 1. **Source Stage**
- Monitors the Hacker News API (`https://hacker-news.firebaseio.com/v0/maxitem.json`) every 30 seconds
- Determines the range of new items to fetch based on the last processed item
- Batches items for efficient processing (configurable batch sizes)

### 2. **Processing Stages**
- **Apply Stage**: Fetches item ranges from the Hacker News API
- **Sequence Stage**: Placeholder for sequential processing operations
- **Accumulate Stage**: Buffers items until reaching size/time thresholds, then processes them
- **Final Apply Stage**: Writes data to Parquet files and commits to Iceberg tables

### 3. **Storage**
- Uses Apache Iceberg table format for ACID transactions and schema evolution
- Stores data in Parquet format with optimized settings for compression and query performance
- Supports S3 storage backends

## Features

- **Incremental Processing**: Only processes new items since the last run
- **Fault Tolerance**: Handles API errors and network issues gracefully
- **Configurable Batching**: Adjustable batch sizes for optimal throughput
- **Schema Evolution**: Supports changes to the Hacker News API structure
- **Optimized Storage**: Parquet format with bloom filters and page indexing

## Configuration

The pipeline is configured via `hn/pipeline.yaml`:

### Key Settings
- `PollInterval: 30s` - How often to check for new items
- `MaxWait: 120s` - Maximum time to wait before processing accumulated items
- `MaxSize: 1000000` - Maximum number of items to accumulate before processing

### Environment Variables
- `ICEBERG_DESTINATION_TABLE_LOCATION` - S3 path for the Iceberg table
- `MAX_BATCH_SIZE` - Number of items to fetch per batch (default: 10)
- `MAX_BATCH_PER_RUN` - Maximum batches per polling cycle (default: 100)
- `INIT_START` - Starting item ID for initial runs
- `DEFAULT_START` - Fallback starting item ID

## Data Schema

The pipeline processes Hacker News items with the following structure:
- `id` - Unique item identifier
- `time` - Unix timestamp when item was created
- `type` - Item type (story, comment, job, poll, etc.)
- Additional fields as provided by the Hacker News API

## Running the Pipeline

### Prerequisites
1. ClickHouse server (local or remote)
2. S3 access for Iceberg table storage
3. Network access to Hacker News API

### Execution
```bash
# Navigate to the pipeline directory
cd init/hn

# Run the pipeline with the configuration
agt run --config pipeline.yaml --var ICEBERG_DESTINATION_TABLE_LOCATION=s3://your-bucket/hn_posts --var ORDER_BY=id
```

### Monitoring
- Monitor logs for processing status and any errors
- Check S3 storage for new Parquet files
- Query the Iceberg table to verify data ingestion

## Development

### File Structure
- `pipeline.yaml` - Main pipeline configuration
- `source.sql` - Source query to determine item ranges
- `init.sql` - Initialization query to find the last processed item
- `01_buffer.sql` - Creates buffer table and fetches items
- `02_buffer.sql` - Additional buffer operations
- `03_write.sql` - Writes buffered data to final storage

### Customization
- Modify batch sizes in environment variables or SQL templates
- Adjust polling intervals and buffer limits in `pipeline.yaml`
- Add custom processing logic in the SQL files
- Configure additional ClickHouse settings for performance tuning

## Troubleshooting

### Common Issues
- **Rate Limiting**: Reduce batch sizes if hitting API limits
- **Memory Usage**: Adjust `max_block_size` and buffer settings for large datasets
- **S3 Permissions**: Ensure proper IAM roles for Iceberg table access
- **Network Issues**: Check connectivity to Hacker News API endpoints

### Error Codes
- `8888` - Table does not exist (expected on first run)
- Check logs for ClickHouse-specific error messages

## Performance Tuning

- Increase `MAX_BATCH_SIZE` for higher throughput (but watch API limits)
- Adjust `max_threads` and `max_insert_threads` for parallel processing
- Tune Parquet settings for your query patterns
- Monitor S3 connection limits with `s3_max_connections`

## License

This project uses the AGT pipeline framework. Please check individual component licenses for compliance requirements.
