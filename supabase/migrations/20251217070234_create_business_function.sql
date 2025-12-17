-- Create atomic business creation function
create function create_business(
  p_name text,
  p_industry text default null,
  p_timezone text default null,
  p_default_reply_tone text default null
) returns uuid
language plpgsql
security definer
as $$
declare
  v_business_id uuid;
begin
  -- Insert business
  insert into businesses (
    name,
    industry,
    timezone,
    default_reply_tone
  )
  values (
    p_name,
    p_industry,
    p_timezone,
    p_default_reply_tone
  )
  returning id into v_business_id;

  -- Assign owner role (atomic with business creation)
  insert into user_business_roles (
    user_id,
    business_id,
    role
  )
  values (
    auth.uid(),
    v_business_id,
    'owner'
  );

  return v_business_id;
end;
$$;

-- Grant execute permission to authenticated users
grant execute on function create_business(text, text, text, text) to authenticated;