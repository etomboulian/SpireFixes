/*
    Since there were no GL Segments to start with
    to rollback we just drop everything that was added

    DO NOT Run this unless your starting point is an empty table for gl_history segments
*/ TRUNCATE gl_history_segments;