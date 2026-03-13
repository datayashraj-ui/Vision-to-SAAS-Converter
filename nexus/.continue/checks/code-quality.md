# Continue CLI — Code Quality Check

Rate all code changes on quality. Look for:

## Must Fix (score < 6 fails PR)
- Functions longer than 80 lines without clear reason
- Deep nesting (> 4 levels) without extraction
- Duplicate logic that could be a shared function
- Missing error handling on async operations
- Unhandled Promise rejections
- Memory leaks (event listeners not cleaned up, intervals not cleared)
- TypeScript `any` type used where a proper type is possible

## Should Fix (noted, doesn't fail)
- Missing input validation on tRPC mutations
- Console.log left in production code
- Magic numbers without named constants
- Functions that do more than one thing
- Variables named `x`, `temp`, `data` without context
- Missing loading states on async UI operations

## Voice AI Specific
- Audio stream not properly closed/cleaned up on call end
- WebSocket connections not cleaned up on component unmount
- TTS requests not cancelled when component unmounts
- Missing timeout on external AI service calls (Whisper, Kokoro)
- Call state not properly reset between calls

## Performance
- N+1 query patterns in database code
- Missing database indexes on filtered/sorted columns
- Loading entire audio file into memory instead of streaming
- Synchronous operations blocking the event loop

## Output Format
Rate quality: [1-10]
Issues found: [list with file:line references]
Recommendation: [PASS / FAIL / WARN]
