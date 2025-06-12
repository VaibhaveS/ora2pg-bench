```

BenchmarkDotNet v0.13.12, Debian GNU/Linux 12 (bookworm) (container)
Intel Xeon Silver 4214R CPU 2.40GHz, 1 CPU, 48 logical and 24 physical cores
.NET SDK 9.0.300
  [Host]     : .NET 9.0.5 (9.0.525.21509), X64 RyuJIT AVX-512F+CD+BW+DQ+VL
  DefaultJob : .NET 9.0.5 (9.0.525.21509), X64 RyuJIT AVX-512F+CD+BW+DQ+VL


```
| Method    | SchemaFile        | Mean     | Error   | StdDev   | Allocated |
|---------- |------------------ |---------:|--------:|---------:|----------:|
| **RunOra2Pg** | **large_schema.sql**  | **308.1 ms** | **6.08 ms** | **12.55 ms** |  **52.04 KB** |
| **RunOra2Pg** | **medium_schema.sql** | **290.3 ms** | **5.81 ms** |  **8.86 ms** |  **50.91 KB** |
| **RunOra2Pg** | **small_schema.sql**  | **284.8 ms** | **5.62 ms** |  **5.52 ms** |  **50.07 KB** |
