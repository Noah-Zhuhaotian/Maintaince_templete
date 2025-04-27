using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TodoApi.Data;
using TodoApi.Models;

namespace TodoApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TodoItemsController : ControllerBase
    {
        private readonly TodoDbContext _context;
        private readonly ILogger<TodoItemsController> _logger;

        public TodoItemsController(TodoDbContext context, ILogger<TodoItemsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: api/TodoItems
        [HttpGet]
        public async Task<ActionResult<IEnumerable<TodoItem>>> GetTodoItems()
        {
            _logger.LogInformation("Getting all todo items");
            return await _context.TodoItems.ToListAsync();
        }

        // GET: api/TodoItems/5
        [HttpGet("{id}")]
        public async Task<ActionResult<TodoItem>> GetTodoItem(long id)
        {
            _logger.LogInformation("Getting todo item with id: {TodoItemId}", id);
            
            var todoItem = await _context.TodoItems.FindAsync(id);

            if (todoItem == null)
            {
                _logger.LogWarning("Todo item with id: {TodoItemId} not found", id);
                return NotFound();
            }

            return todoItem;
        }

        // PUT: api/TodoItems/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutTodoItem(long id, TodoItem todoItem)
        {
            if (id != todoItem.Id)
            {
                return BadRequest();
            }

            _context.Entry(todoItem).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
                _logger.LogInformation("Todo item with id: {TodoItemId} updated successfully", id);
            }
            catch (DbUpdateConcurrencyException ex)
            {
                if (!TodoItemExists(id))
                {
                    _logger.LogWarning("Todo item with id: {TodoItemId} not found during update", id);
                    return NotFound();
                }
                else
                {
                    _logger.LogError(ex, "Error updating todo item with id: {TodoItemId}", id);
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/TodoItems
        [HttpPost]
        public async Task<ActionResult<TodoItem>> PostTodoItem(TodoItem todoItem)
        {
            todoItem.CreatedAt = DateTime.UtcNow;
            _context.TodoItems.Add(todoItem);
            await _context.SaveChangesAsync();

            _logger.LogInformation("New todo item created with id: {TodoItemId}", todoItem.Id);

            return CreatedAtAction(nameof(GetTodoItem), new { id = todoItem.Id }, todoItem);
        }

        // DELETE: api/TodoItems/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteTodoItem(long id)
        {
            var todoItem = await _context.TodoItems.FindAsync(id);
            if (todoItem == null)
            {
                _logger.LogWarning("Todo item with id: {TodoItemId} not found during delete attempt", id);
                return NotFound();
            }

            _context.TodoItems.Remove(todoItem);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Todo item with id: {TodoItemId} deleted successfully", id);

            return NoContent();
        }

        // POST: api/TodoItems/5/complete
        [HttpPost("{id}/complete")]
        public async Task<IActionResult> CompleteTodoItem(long id)
        {
            var todoItem = await _context.TodoItems.FindAsync(id);
            
            if (todoItem == null)
            {
                _logger.LogWarning("Todo item with id: {TodoItemId} not found during complete attempt", id);
                return NotFound();
            }

            todoItem.IsComplete = true;
            todoItem.CompletedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            _logger.LogInformation("Todo item with id: {TodoItemId} marked as complete", id);

            return NoContent();
        }

        private bool TodoItemExists(long id)
        {
            return _context.TodoItems.Any(e => e.Id == id);
        }
    }
}