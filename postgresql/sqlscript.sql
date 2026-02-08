CREATE SCHEMA IF NOT EXISTS metricbeat;

CREATE TABLE IF NOT EXISTS metricbeat.metricbeat_events (
    id BIGSERIAL PRIMARY KEY,
    event_time TIMESTAMP NOT NULL,
    host_name TEXT,
    event_module TEXT,
    metricset_name TEXT,
    event_dataset TEXT,
    raw_event JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE INDEX idx_metricbeat_event_time
  ON metricbeat.metricbeat_events(event_time);

CREATE INDEX idx_metricbeat_host
  ON metricbeat.metricbeat_events(host_name);

CREATE INDEX idx_metricbeat_dataset
  ON metricbeat.metricbeat_events(event_dataset);




--##########################INSERT INTO TABLE SCRIPT###############################################

INSERT INTO metricbeat.unified_metrics (
    -- Event metadata
    event_time,
    event_module,
    metricset_name,
    event_dataset,
    event_duration,
    
    -- Host information
    host_id,
    host_name,
    hostname,
    host_architecture,
    host_ips,
    host_macs,
    
    -- OS information
    os_name,
    os_type,
    os_family,
    os_version,
    os_build,
    os_kernel,
    os_platform,
    
    -- User information
    user_name,
    
    -- Process metrics
    process_pid,
    process_name,
    process_state,
    process_parent_pid,
    process_command_line,
    process_args,
    process_num_threads,
    process_cpu_pct,
    process_cpu_pct_norm,
    process_cpu_total_value,
    process_cpu_start_time,
    process_memory_rss_bytes,
    process_memory_rss_pct,
    process_memory_size_bytes,
    
    -- CPU metrics
    cpu_core,
    cpu_core_pct,
    cpu_system_pct,
    cpu_user_pct,
    cpu_idle_pct,
    cpu_iowait_pct,
    cpu_irq_pct,
    cpu_nice_pct,
    cpu_softirq_pct,
    cpu_steal_pct,
    
    -- Memory metrics
    memory_total_bytes,
    memory_used_bytes,
    memory_used_pct,
    memory_free_bytes,
    memory_actual_free_bytes,
    memory_actual_used_bytes,
    memory_actual_used_pct,
    memory_swap_total_bytes,
    memory_swap_used_bytes,
    memory_swap_used_pct,
    memory_swap_free_bytes,
    
    -- Network metrics
    network_name,
    network_in_bytes,
    network_in_packets,
    network_in_errors,
    network_in_dropped,
    network_out_bytes,
    network_out_packets,
    network_out_errors,
    network_out_dropped,
    
    -- Disk metrics
    disk_device_name,
    disk_mount_point,
    disk_fs_type,
    disk_total_bytes,
    disk_used_bytes,
    disk_used_pct,
    disk_available_bytes,
    disk_files_total,
    disk_files_used,
    
    -- Socket metrics
    socket_listening,
    socket_total,
    socket_tcp_established,
    socket_tcp_closing,
    socket_tcp_time_wait,
    socket_udp_total,
    
    -- Load metrics
    load_1m,
    load_5m,
    load_15m,
    load_cores,
    
    -- Uptime metrics
    uptime_duration_ms,
    
    -- Raw event
    raw_event
)
SELECT
    -- Event metadata
    event_time,
    event_module,
    metricset_name,
    event_dataset,
    (raw_event->'event'->>'duration')::float,
    
    -- Host information
    raw_event->'host'->>'id',
    raw_event->'host'->>'name',
    raw_event->'host'->>'hostname',
    raw_event->'host'->>'architecture',
    raw_event->'host'->'ip',
    raw_event->'host'->'mac',
    
    -- OS information
    raw_event->'host'->'os'->>'name',
    raw_event->'host'->'os'->>'type',
    raw_event->'host'->'os'->>'family',
    raw_event->'host'->'os'->>'version',
    raw_event->'host'->'os'->>'build',
    raw_event->'host'->'os'->>'kernel',
    raw_event->'host'->'os'->>'platform',
    
    -- User information
    raw_event->'user'->>'name',
    
    -- Process metrics (conditional on event type)
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'process'->>'pid')::integer END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN raw_event->'process'->>'name' END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN raw_event->'process'->>'state' END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'process'->'parent'->>'pid')::integer END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN raw_event->'process'->>'command_line' END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN raw_event->'process'->'args' END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->>'num_threads')::integer END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'process'->'cpu'->>'pct')::decimal END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->'cpu'->'total'->'norm'->>'pct')::decimal END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->'cpu'->'total'->>'value')::float END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'process'->'cpu'->>'start_time')::timestamp END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->'memory'->'rss'->>'bytes')::float END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->'memory'->'rss'->>'pct')::decimal END,
    CASE WHEN event_dataset LIKE 'system.process%' 
        THEN (raw_event->'system'->'process'->'memory'->>'size')::float END,
    
    -- CPU metrics
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'core')::integer END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'total.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'system.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'user.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'idle.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'iowait.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'irq.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'nice.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'softirq.pct')::decimal END,
    CASE WHEN event_dataset = 'system.cpu' 
        THEN (raw_event->'system'->'cpu'->>'steal.pct')::decimal END,
    
    -- Memory metrics
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->>'total')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'used'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'used'->>'pct')::decimal END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->>'free')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'actual'->>'free')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'actual'->'used'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'actual'->'used'->>'pct')::decimal END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'swap'->>'total')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'swap'->'used'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'swap'->'used'->>'pct')::decimal END,
    CASE WHEN event_dataset = 'system.memory' 
        THEN (raw_event->'system'->'memory'->'swap'->>'free')::float END,
    
    -- Network metrics
    CASE WHEN event_dataset = 'system.network' 
        THEN raw_event->'system'->'network'->>'name' END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'in'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'in'->>'packets')::float END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'in'->>'errors')::integer END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'in'->>'dropped')::integer END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'out'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'out'->>'packets')::float END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'out'->>'errors')::integer END,
    CASE WHEN event_dataset = 'system.network' 
        THEN (raw_event->'system'->'network'->'out'->>'dropped')::integer END,
    
    -- Disk metrics
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN raw_event->'system'->'filesystem'->>'device_name' END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN raw_event->'system'->'filesystem'->>'mount_point' END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN raw_event->'system'->'filesystem'->>'type' END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->>'total')::float END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->'used'->>'bytes')::float END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->'used'->>'pct')::decimal END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->>'available')::float END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->'files'->>'total')::float END,
    CASE WHEN event_dataset = 'system.filesystem' 
        THEN (raw_event->'system'->'filesystem'->'files'->>'used')::float END,
    
    -- Socket metrics
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'all'->>'listening')::integer END,
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'all'->>'count')::integer END,
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'tcp'->'all'->>'established')::integer END,
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'tcp'->'all'->>'closing')::integer END,
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'tcp'->'all'->>'time_wait')::integer END,
    CASE WHEN event_dataset = 'system.socket.summary' 
        THEN (raw_event->'system'->'socket'->'summary'->'udp'->'all'->>'count')::integer END,
    
    -- Load metrics
    CASE WHEN event_dataset = 'system.load' 
        THEN (raw_event->'system'->'load'->>'1')::decimal END,
    CASE WHEN event_dataset = 'system.load' 
        THEN (raw_event->'system'->'load'->>'5')::decimal END,
    CASE WHEN event_dataset = 'system.load' 
        THEN (raw_event->'system'->'load'->>'15')::decimal END,
    CASE WHEN event_dataset = 'system.load' 
        THEN (raw_event->'system'->'load'->>'cores')::integer END,
    
    -- Uptime metrics
    CASE WHEN event_dataset = 'system.uptime' 
        THEN (raw_event->'system'->'uptime'->>'duration.ms')::float END,
    
    -- Raw event
    raw_event
FROM metricbeat.metricbeat_events;