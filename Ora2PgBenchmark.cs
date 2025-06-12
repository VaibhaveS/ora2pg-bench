using System;
using System.Diagnostics;
using System.IO;
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Configs;
using BenchmarkDotNet.Jobs;
using BenchmarkDotNet.Diagnosers;

namespace Ora2PgBenchmark
{
    [MemoryDiagnoser]
    public class Ora2PgBenchmarks
    {
        [Params("small_schema.sql", "medium_schema.sql", "large_schema.sql")]
        public string SchemaFile { get; set; } = "small_schema.sql";

        private string _ora2pgPath = string.Empty;

        [GlobalSetup]
        public void Setup()
        {
            // Verify ora2pg is installed
            _ora2pgPath = "ora2pg"; // Assuming it's in PATH
            var processInfo = new ProcessStartInfo
            {
                FileName = _ora2pgPath,
                Arguments = "--version",
                RedirectStandardOutput = true,
                UseShellExecute = false
            };

            using var checkProcess = Process.Start(processInfo)
                ?? throw new Exception("Failed to start ora2pg process");

            checkProcess.WaitForExit();

            if (checkProcess.ExitCode != 0)
            {
                throw new Exception("ora2pg is not installed or not found in PATH");
            }
        }

        [Benchmark]
        public void RunOra2Pg()
        {
            var processInfo = new ProcessStartInfo
            {
                FileName = _ora2pgPath,
                Arguments = $"-i {SchemaFile} -o output_{Path.GetFileNameWithoutExtension(SchemaFile)}.sql",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false
            };

            using var process = Process.Start(processInfo)
                ?? throw new Exception("Failed to start ora2pg process");

            process.WaitForExit(); string output = process.StandardOutput.ReadToEnd();
            string error = process.StandardError.ReadToEnd();

            if (process.ExitCode != 0)
            {
                throw new Exception($"ora2pg failed with exit code {process.ExitCode}. Error: {error}");
            }
        }
    }

    public class Program
    {
        public static void Main(string[] args)
        {
            var config = ManualConfig.Create(DefaultConfig.Instance)
                .AddDiagnoser(MemoryDiagnoser.Default);

            BenchmarkDotNet.Running.BenchmarkRunner.Run<Ora2PgBenchmarks>(config);
        }
    }
}
