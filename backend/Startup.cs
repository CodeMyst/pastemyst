using System.Collections.Generic;
using System.IO;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using PasteMyst.Models;
using PasteMyst.Services;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace PasteMyst
{
    public class Startup
    {
        private Dictionary<string, Language> _langs = new();

        private readonly IConfiguration _config;

        public Startup(IConfiguration config)
        {
            _config = config;
        }

        public void ConfigureServices(IServiceCollection services)
        {
            LoadLangs();

            services.Configure<DatabaseSettings>(_config.GetSection(nameof(DatabaseSettings)));
            services.AddSingleton<IDatabaseSettings>(sp => sp.GetRequiredService<IOptions<DatabaseSettings>>().Value);

            services.AddSingleton<LanguageService>();
            services.AddSingleton<PasteService>();
            services.AddSingleton(_langs);

            // TODO: this is only temporary, later cors should be defined per endpoints
            services.AddCors(options =>
            {
                options.AddDefaultPolicy(builder =>
                {
                    builder.WithOrigins("*")
                           .AllowAnyHeader();
                });
            });

            services.AddControllers().AddNewtonsoftJson();

            services.AddApiVersioning();
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            app.UseCors();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();

                endpoints.MapGet("/", async context =>
                {
                    await context.Response.WriteAsync("Hello World!");
                });
            });
        }

        /// <summary>
        /// Loads languages.yml and deserializes them into a dictionary. Available through DI.
        /// </summary>
        private void LoadLangs()
        {
            string yaml = File.ReadAllText("Data/languages.yml");

            IDeserializer deserializer = new DeserializerBuilder()
                .WithNamingConvention(UnderscoredNamingConvention.Instance)
                .IgnoreUnmatchedProperties()
                .Build();

            _langs = deserializer.Deserialize<Dictionary<string, Language>>(yaml);
        }
    }
}
