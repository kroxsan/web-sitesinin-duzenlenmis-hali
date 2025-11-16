using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using site_backend.Data;
using site_backend.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace site_backend.Controllers
{
    [Authorize]
    [Route("api/[controller]")]
    [ApiController]
    public class EventsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EventsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/events
        [AllowAnonymous]
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Event>>> GetEvents()
        {
            var events = await _context.Events.ToListAsync(); //veritabanındaki tüm etkinlikleri çeker
            return Ok(events);
        }

        // GET: api/events/5
        [AllowAnonymous]
        [HttpGet("{id}")]       //sonrasında kullanılabilir
        public async Task<ActionResult<Event>> GetEvent(int id)
        {
            var ev = await _context.Events.FindAsync(id);  //belirli bir etkinliği id'sine göre çeker
            if (ev == null) return NotFound();
            return ev;
        }

        // POST: api/events
        [HttpPost]
        public async Task<ActionResult<Event>> CreateEvent(Event ev)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null)
                return Unauthorized();

            ev.UserId = int.Parse(userIdClaim.Value);

            _context.Events.Add(ev);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEvent), new { id = ev.Id }, ev);
        }

        // PUT: api/events/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEvent(int id, Event ev)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            if (id != ev.Id) return BadRequest();

            var existingEvent = await _context.Events
                .Where(e => e.Id == id && e.UserId == userId)
                .FirstOrDefaultAsync();

            if (existingEvent == null) return NotFound();

            existingEvent.Name = ev.Name;
            existingEvent.Description = ev.Description;
            existingEvent.Date = ev.Date;
            existingEvent.Category = ev.Category;
            existingEvent.City = ev.City;
            existingEvent.Price = ev.Price;
            existingEvent.ImageUrl = ev.ImageUrl;
            existingEvent.Location = ev.Location;
            existingEvent.Capacity = ev.Capacity;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/events/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEvent(int id)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var ev = await _context.Events          //_context.Events = veritabanındaki Events tablosuna erişim sağlıyor
                .Where(e => e.Id == id && e.UserId == userId)
                .FirstOrDefaultAsync();

            if (ev == null) return NotFound();

            _context.Events.Remove(ev);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
