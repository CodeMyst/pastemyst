using System.Collections.Generic;
using System.IO;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using PasteMyst.Model;
using YamlDotNet.Serialization;
using YamlDotNet.Serialization.NamingConventions;

namespace PasteMyst
{
    public class Startup
    {
        private Dictionary<string, Language> _langs = new();

        public void ConfigureServices(IServiceCollection services)
        {
            LoadLangs();

            // TODO: this is only temporary, later cors should be defined per endpoints
            services.AddCors(options =>
            {
                options.AddDefaultPolicy(builder =>
                {
                    builder.WithOrigins("*")
                           .AllowAnyHeader();
                });
            });

            services.AddControllers();
            services.AddApiVersioning();
            services.AddSingleton(_langs);
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
            var yaml = File.ReadAllText("Data/languages.yml");

            var deserializer = new DeserializerBuilder()
                .WithNamingConvention(UnderscoredNamingConvention.Instance)
                .IgnoreUnmatchedProperties()
                .Build();

            _langs = deserializer.Deserialize<Dictionary<string, Language>>(yaml);
        }
    }
}
