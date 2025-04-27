using Microsoft.EntityFrameworkCore;
using TodoApi.Models;

namespace TodoApi.Data
{
    public class TodoDbContext : DbContext
    {
        public TodoDbContext(DbContextOptions<TodoDbContext> options)
            : base(options)
        {
        }

        public DbSet<TodoItem> TodoItems { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure TodoItem entity
            modelBuilder.Entity<TodoItem>()
                .HasKey(t => t.Id);

            modelBuilder.Entity<TodoItem>()
                .Property(t => t.Name)
                .IsRequired()
                .HasMaxLength(100);

            modelBuilder.Entity<TodoItem>()
                .Property(t => t.Description)
                .HasMaxLength(500);

            modelBuilder.Entity<TodoItem>()
                .Property(t => t.CreatedAt)
                .IsRequired();

            // Add seed data
            modelBuilder.Entity<TodoItem>().HasData(
                new TodoItem
                {
                    Id = 1,
                    Name = "Learn ASP.NET Core",
                    Description = "Take online course and build a sample application",
                    IsComplete = false,
                    Priority = 2,
                    CreatedAt = DateTime.UtcNow
                },
                new TodoItem
                {
                    Id = 2,
                    Name = "Deploy to Azure",
                    Description = "Deploy application to Azure App Service",
                    IsComplete = false,
                    Priority = 1,
                    CreatedAt = DateTime.UtcNow
                }
            );
        }
    }
}