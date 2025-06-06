/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* config
env {
parallelism = 1
job.mode = "BATCH"
}
*/

CREATE TABLE source_table
WITH (
        'connector' = 'jdbc',
        'type' = 'source',
        'url' = 'jdbc:postgresql://localhost:5432/test',
        'driver' = 'org.postgresql.Driver',
        'connection_check_timeout_sec' = '100',
        'user' = 'test',
        'database' = 'test',
        'password' = 'test',
        'table_list' = '[
      {
        table_path = "test.public.assets"
      },
      {
        table_path = "test.public.products"
      }
    ]',
        'split.size' = '8096',
        'split.even-distribution.factor.upper-bound' = '100',
        'split.even-distribution.factor.lower-bound' = '0.05',
        'split.sample-sharding.threshold' = '1000',
        'split.inverse-sampling.rate' = '1000'
    );

CREATE TABLE sink_table
WITH (
        'connector' = 'jdbc',
        'type' = 'sink',
        'url' = 'jdbc:mysql://localhost:3306/test',
        'driver' = 'com.mysql.cj.jdbc.Driver',
        'user' = 'test',
        'password' = 'test',
        'generate_sink_sql' = 'true',
        'database' = 'test_sink',
        'table' = '${table_name}'
    );

-- If it's multi-table synchronization, there's no need to set select columns.
-- You can directly use the syntax 'INSERT INTO sink_table SELECT source_table'.
INSERT INTO sink_table SELECT source_table;