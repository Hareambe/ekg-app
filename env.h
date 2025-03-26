#ifndef ENV_H
#define ENV_H

#include <QString>

extern QString SUPABASE_URL;
extern QString SUPABASE_API_KEY;

// Call this function at startup to initialize the environment variables.
void initEnv();

#endif // ENV_H
