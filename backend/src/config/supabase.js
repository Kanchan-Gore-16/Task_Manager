import { createClient, SupabaseClient } from "@supabase/supabase-js";
import dotenv from "dotenv";

//Supabase client configuration
dotenv.config();

const supabaseURL = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseURL, supabaseKey);

export { supabase };
