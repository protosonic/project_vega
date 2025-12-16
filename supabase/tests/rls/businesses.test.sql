BEGIN;

-- Test businesses table RLS policies
-- This test suite verifies that businesses table RLS policies work correctly
--
-- Policies tested:
-- - SELECT: owner/admin can view businesses they have roles for
-- - INSERT: any authenticated user can create businesses
-- - UPDATE: owner/admin can update businesses they have roles for
-- - DELETE: only owner can delete businesses they own

-- Setup test data
INSERT INTO auth.users (id, email) VALUES
    ('11111111-1111-1111-1111-111111111111', 'owner@example.com'),
    ('22222222-2222-2222-2222-222222222222', 'admin@example.com'),
    ('33333333-3333-3333-3333-333333333333', 'staff@example.com'),
    ('44444444-4444-4444-4444-444444444444', 'viewer@example.com'),
    ('55555555-5555-5555-5555-555555555555', 'unauthorized@example.com');

INSERT INTO public.user_profiles (id, first_name, last_name, role) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Test', 'Owner', 'owner'),
    ('22222222-2222-2222-2222-222222222222', 'Test', 'Admin', 'admin'),
    ('33333333-3333-3333-3333-333333333333', 'Test', 'Staff', 'member'),
    ('44444444-4444-4444-4444-444444444444', 'Test', 'Viewer', 'member'),
    ('55555555-5555-5555-5555-555555555555', 'Test', 'Unauthorized', 'member');

INSERT INTO public.businesses (id, name, industry) VALUES
    (1, 'Test Business 1', 'restaurant'),
    (2, 'Test Business 2', 'retail'),
    (3, 'Test Business 3', 'hospitality');

INSERT INTO public.user_business_roles (user_id, business_id, role) VALUES
    -- User 1 (owner) owns business 1
    ('11111111-1111-1111-1111-111111111111', 1, 'owner'),
    -- User 2 (admin) is admin of business 1
    ('22222222-2222-2222-2222-222222222222', 1, 'admin'),
    -- User 3 (staff) is staff of business 1
    ('33333333-3333-3333-3333-333333333333', 1, 'staff'),
    -- User 4 (viewer) is viewer of business 1
    ('44444444-4444-4444-4444-444444444444', 1, 'viewer'),
    -- User 1 (owner) also owns business 2
    ('11111111-1111-1111-1111-111111111111', 2, 'owner');

-- Test 1: Owner can SELECT their businesses
SELECT set_config('request.jwt.claims', '{"sub": "11111111-1111-1111-1111-111111111111"}', true);
SELECT results_eq(
    'SELECT COUNT(*) FROM public.businesses',
    ARRAY[2::bigint],
    'Owner should be able to select 2 businesses they own'
);

-- Test 2: Admin can SELECT businesses they have admin role for
SELECT set_config('request.jwt.claims', '{"sub": "22222222-2222-2222-2222-222222222222"}', true);
SELECT results_eq(
    'SELECT COUNT(*) FROM public.businesses',
    ARRAY[1::bigint],
    'Admin should be able to select 1 business they administer'
);

-- Test 3: Staff cannot SELECT businesses (only owner/admin can select)
SELECT set_config('request.jwt.claims', '{"sub": "33333333-3333-3333-3333-333333333333"}', true);
SELECT results_eq(
    'SELECT COUNT(*) FROM public.businesses',
    ARRAY[0::bigint],
    'Staff should not be able to select businesses'
);

-- Test 4: Viewer cannot SELECT businesses (only owner/admin can select)
SELECT set_config('request.jwt.claims', '{"sub": "44444444-4444-4444-4444-444444444444"}', true);
SELECT results_eq(
    'SELECT COUNT(*) FROM public.businesses',
    ARRAY[0::bigint],
    'Viewer should not be able to select businesses'
);

-- Test 5: Unauthorized user cannot SELECT any businesses
SELECT set_config('request.jwt.claims', '{"sub": "55555555-5555-5555-5555-555555555555"}', true);
SELECT results_eq(
    'SELECT COUNT(*) FROM public.businesses',
    ARRAY[0::bigint],
    'Unauthorized user should not be able to select any businesses'
);

-- Test 6: Authenticated users can INSERT new businesses
SELECT set_config('request.jwt.claims', '{"sub": "11111111-1111-1111-1111-111111111111"}', true);
SELECT lives_ok(
    'INSERT INTO public.businesses (name, industry) VALUES (''New Business'', ''tech'')',
    'Authenticated users should be able to insert new businesses'
);

-- Test 7: Owner can UPDATE their businesses
SELECT set_config('request.jwt.claims', '{"sub": "11111111-1111-1111-1111-111111111111"}', true);
SELECT lives_ok(
    'UPDATE public.businesses SET name = ''Updated Business 1'' WHERE id = 1',
    'Owner should be able to update their businesses'
);

-- Test 8: Admin can UPDATE businesses they administer
SELECT set_config('request.jwt.claims', '{"sub": "22222222-2222-2222-2222-222222222222"}', true);
SELECT lives_ok(
    'UPDATE public.businesses SET name = ''Admin Updated Business 1'' WHERE id = 1',
    'Admin should be able to update businesses they administer'
);

-- Test 9: Staff cannot UPDATE businesses
SELECT set_config('request.jwt.claims', '{"sub": "33333333-3333-3333-3333-333333333333"}', true);
SELECT throws_ok(
    'UPDATE public.businesses SET name = ''Staff Update'' WHERE id = 1',
    '42501',
    'Staff should not be able to update businesses'
);

-- Test 10: Owner can DELETE their businesses
SELECT set_config('request.jwt.claims', '{"sub": "11111111-1111-1111-1111-111111111111"}', true);
SELECT lives_ok(
    'DELETE FROM public.businesses WHERE id = 2',
    'Owner should be able to delete their businesses'
);

-- Test 11: Admin cannot DELETE businesses (only owner can delete)
SELECT set_config('request.jwt.claims', '{"sub": "22222222-2222-2222-2222-222222222222"}', true);
SELECT throws_ok(
    'DELETE FROM public.businesses WHERE id = 1',
    '42501',
    'Admin should not be able to delete businesses'
);

-- Test 12: Staff cannot DELETE businesses
SELECT set_config('request.jwt.claims', '{"sub": "33333333-3333-3333-3333-333333333333"}', true);
SELECT throws_ok(
    'DELETE FROM public.businesses WHERE id = 1',
    '42501',
    'Staff should not be able to delete businesses'
);

-- Test 13: Verify RLS is enabled on businesses table
SELECT has_rls('public', 'businesses');

-- Test 14: Verify correct policies exist
SELECT policies_are('public', 'businesses', ARRAY['businesses_select', 'businesses_insert', 'businesses_update', 'businesses_delete']);

ROLLBACK;