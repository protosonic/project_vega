"use client";

import { cn } from "@/lib/utils";
import { createBusiness } from "@/app/actions/create-business";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useRouter } from "next/navigation";
import { useState, useTransition } from "react";

export function CreateBusinessForm({
  className,
  ...props
}: React.ComponentPropsWithoutRef<"div">) {
  const [name, setName] = useState("");
  const [industry, setIndustry] = useState("");
  const [timezone, setTimezone] = useState("");
  const [defaultReplyTone, setDefaultReplyTone] = useState("");
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isPending, startTransition] = useTransition();
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setErrors({});

    // Client-side validation
    const clientErrors: Record<string, string> = {};
    if (!name.trim()) {
      clientErrors.name = "Business name is required";
    }

    if (Object.keys(clientErrors).length > 0) {
      setErrors(clientErrors);
      return;
    }

    const formData = new FormData();
    formData.append("name", name.trim());
    if (industry) formData.append("industry", industry);
    if (timezone) formData.append("timezone", timezone);
    if (defaultReplyTone) formData.append("defaultReplyTone", defaultReplyTone);

    startTransition(async () => {
      const result = await createBusiness(formData);

      if (result.success && result.businessId) {
        router.push(`/dashboard/businesses/${result.businessId}`);
      } else {
        setErrors(result.errors || { general: "An error occurred" });
      }
    });
  };

  const industries = [
    "restaurant",
    "retail",
    "hospitality",
    "healthcare",
    "automotive",
    "professional_services",
    "other",
  ];

  const timezones = [
    "America/New_York",
    "America/Chicago",
    "America/Denver",
    "America/Los_Angeles",
    "Europe/London",
    "Europe/Paris",
    "Asia/Tokyo",
    "Australia/Sydney",
  ];

  return (
    <div className={cn("flex flex-col gap-6", className)} {...props}>
      <Card>
        <CardHeader>
          <CardTitle className="text-2xl">Create Your Business</CardTitle>
          <CardDescription>
            Set up your business profile to start managing reviews
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit}>
            <div className="flex flex-col gap-6">
              <div className="grid gap-2">
                <Label htmlFor="name">Business Name *</Label>
                <Input
                  id="name"
                  type="text"
                  placeholder="Enter your business name"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  disabled={isPending}
                />
                {errors.name && (
                  <p className="text-sm text-red-500">{errors.name}</p>
                )}
              </div>

              <div className="grid gap-2">
                <Label htmlFor="industry">Industry</Label>
                <Select value={industry} onValueChange={setIndustry} disabled={isPending}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select your industry" />
                  </SelectTrigger>
                  <SelectContent>
                    {industries.map((ind) => (
                      <SelectItem key={ind} value={ind}>
                        {ind.replace("_", " ").replace(/\b\w/g, l => l.toUpperCase())}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="grid gap-2">
                <Label htmlFor="timezone">Timezone</Label>
                <Select value={timezone} onValueChange={setTimezone} disabled={isPending}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select your timezone" />
                  </SelectTrigger>
                  <SelectContent>
                    {timezones.map((tz) => (
                      <SelectItem key={tz} value={tz}>
                        {tz}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div className="grid gap-2">
                <Label htmlFor="defaultReplyTone">Default Reply Tone</Label>
                <Textarea
                  id="defaultReplyTone"
                  placeholder="Describe your preferred tone for review responses (e.g., professional, friendly, empathetic)"
                  value={defaultReplyTone}
                  onChange={(e) => setDefaultReplyTone(e.target.value)}
                  disabled={isPending}
                  rows={3}
                />
              </div>

              {errors.general && (
                <p className="text-sm text-red-500">{errors.general}</p>
              )}

              <Button type="submit" className="w-full" disabled={isPending}>
                {isPending ? "Creating Business..." : "Create Business"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}