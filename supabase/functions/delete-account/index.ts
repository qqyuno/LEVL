// LEVL — Edge Function: Delete Account
// Validates the user JWT, deletes app data, then removes the Supabase auth user.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return jsonResponse({ ok: true });
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return jsonResponse({ error: "Missing Authorization header" }, 401);
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      return jsonResponse({ error: "Delete account is not configured" }, 500);
    }

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: authError,
    } = await userClient.auth.getUser();

    if (authError || !user) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const admin = createClient(supabaseUrl, serviceRoleKey);

    await deleteRows(admin, "quest_cache", "user_id", user.id);
    await deleteRows(admin, "quests", "user_id", user.id);
    await deleteRows(admin, "daily_checkins", "user_id", user.id);
    await deleteRows(admin, "profiles", "id", user.id);

    const { error: deleteUserError } = await admin.auth.admin.deleteUser(user.id);
    if (deleteUserError) {
      console.error("deleteUser error:", deleteUserError.message);
      return jsonResponse({ error: "Failed to delete auth user" }, 500);
    }

    return jsonResponse({ ok: true });
  } catch (error) {
    console.error("delete-account error:", error);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});

async function deleteRows(
  client: any,
  table: string,
  column: string,
  userId: string,
) {
  const { error } = await client.from(table).delete().eq(column, userId);
  if (error) {
    throw new Error(`${table}: ${error.message}`);
  }
}

function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
    },
  });
}
