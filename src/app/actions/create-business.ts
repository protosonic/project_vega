"use server";

import { createClient } from "@/lib/supabase/server";
import { z } from "zod";

const createBusinessSchema = z.object({
  name: z.string().min(1, "Business name is required").max(100, "Business name is too long"),
  industry: z.string().optional(),
  timezone: z.string().optional(),
  defaultReplyTone: z.string().optional(),
});

export type CreateBusinessInput = z.infer<typeof createBusinessSchema>;

export async function createBusiness(formData: FormData) {
  try {
    const supabase = await createClient();

    // Get authenticated user
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return {
        success: false,
        errors: { auth: "You must be logged in to create a business" },
      };
    }

    // Parse and validate form data
    const rawData = {
      name: formData.get("name")?.toString() || "",
      industry: formData.get("industry")?.toString(),
      timezone: formData.get("timezone")?.toString(),
      defaultReplyTone: formData.get("defaultReplyTone")?.toString(),
    };

    const validationResult = createBusinessSchema.safeParse(rawData);
    if (!validationResult.success) {
      const errors: Record<string, string> = {};
      validationResult.error.issues.forEach((error: z.ZodIssue) => {
        const field = error.path[0] as string;
        errors[field] = error.message;
      });
      return { success: false, errors };
    }

    const data = validationResult.data;

    // Call atomic Postgres function
    const { data: businessId, error: rpcError } = await supabase.rpc("create_business", {
      p_name: data.name,
      p_industry: data.industry,
      p_timezone: data.timezone,
      p_default_reply_tone: data.defaultReplyTone,
    });

    if (rpcError) {
      console.error("Business creation error:", rpcError);
      return {
        success: false,
        errors: { general: "Failed to create business. Please try again." },
      };
    }

    return { success: true, businessId };
  } catch (error: unknown) {
    console.error("Unexpected error in createBusiness:", error);
    return {
      success: false,
      errors: { general: "An unexpected error occurred. Please try again." },
    };
  }
}