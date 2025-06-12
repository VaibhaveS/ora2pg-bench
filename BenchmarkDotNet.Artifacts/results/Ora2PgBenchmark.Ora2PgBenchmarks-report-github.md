```

BenchmarkDotNet v0.13.12, Debian GNU/Linux 12 (bookworm) (container)
Intel Xeon Silver 4214R CPU 2.40GHz, 1 CPU, 48 logical and 24 physical cores
.NET SDK 9.0.300
  [Host]     : .NET 9.0.5 (9.0.525.21509), X64 RyuJIT AVX-512F+CD+BW+DQ+VL
  DefaultJob : .NET 9.0.5 (9.0.525.21509), X64 RyuJIT AVX-512F+CD+BW+DQ+VL


```
| Method    | SchemaFile        | Mean | Error |
|---------- |------------------ |-----:|------:|
| **RunOra2Pg** | **large_schema.sql**  |   **NA** |    **NA** |
| **RunOra2Pg** | **medium_schema.sql** |   **NA** |    **NA** |
| **RunOra2Pg** | **small_schema.sql**  |   **NA** |    **NA** |

Benchmarks with issues:
  Ora2PgBenchmarks.RunOra2Pg: DefaultJob [SchemaFile=large_schema.sql]
  Ora2PgBenchmarks.RunOra2Pg: DefaultJob [SchemaFile=medium_schema.sql]
  Ora2PgBenchmarks.RunOra2Pg: DefaultJob [SchemaFile=small_schema.sql]
