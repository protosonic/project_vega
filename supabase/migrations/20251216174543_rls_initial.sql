-- BUSINESSES TABLE --
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY businesses_select
ON public.businesses
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = businesses.id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);

-- INSERT (authenticated users can create businesses)
CREATE POLICY businesses_insert
ON public.businesses
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- UPDATE (owners and admins can update)
CREATE POLICY businesses_update
ON public.businesses
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = businesses.id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = businesses.id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);

-- DELETE (owners only)
CREATE POLICY businesses_delete
ON public.businesses
FOR DELETE
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = businesses.id
      AND ubr.user_id = auth.uid()
      AND ubr.role = 'owner'
  )
);

-- USER_BUSINESS_ROLES TABLES --
ALTER TABLE public.user_business_roles ENABLE ROW LEVEL SECURITY;

-- SELECT (self visibility)
CREATE POLICY ubr_select_self
ON public.user_business_roles
FOR SELECT
USING (user_id = auth.uid());

-- INSERT / UPDATE / DELETE (admins & owners)
CREATE POLICY ubr_manage
ON public.user_business_roles
FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles me
    WHERE me.business_id = user_business_roles.business_id
      AND me.user_id = auth.uid()
      AND me.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles me
    WHERE me.business_id = user_business_roles.business_id
      AND me.user_id = auth.uid()
      AND me.role IN ('owner', 'admin')
  )
);

-- REVIEWS TABLES --
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY reviews_select
ON public.reviews
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
  )
);

-- INSERT
CREATE POLICY reviews_insert
ON public.reviews
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin', 'staff')
  )
);

-- UPDATE
CREATE POLICY reviews_update
ON public.reviews
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);

-- DELETE
CREATE POLICY reviews_delete
ON public.reviews
FOR DELETE
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);


-- REVIEW_SOURCES TABLE --
ALTER TABLE public.review_sources ENABLE ROW LEVEL SECURITY;

-- SELECT (all authenticated users can see review sources)
CREATE POLICY review_sources_select
ON public.review_sources
FOR SELECT
USING (auth.uid() IS NOT NULL);

-- INSERT / UPDATE / DELETE (only admins/owners can manage - global config)
CREATE POLICY review_sources_manage
ON public.review_sources
FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ubr
    WHERE ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);

-- USER_PROFILES TABLE --
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY user_profiles_select
ON public.user_profiles
FOR SELECT
USING (id = auth.uid());

-- INSERT
CREATE POLICY user_profiles_insert
ON public.user_profiles
FOR INSERT
WITH CHECK (id = auth.uid());

-- UPDATE
CREATE POLICY user_profiles_update
ON public.user_profiles
FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
