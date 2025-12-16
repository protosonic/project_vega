-- BUSINESSES TABLE --
ALTER TABLE public.businesses ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY businesses_select
ON public.businesses
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_roles ub
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

-- DELETE (optional, often owner-only)
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
ALTER TABLE public.user_business_role ENABLE ROW LEVEL SECURITY;

-- SELECT (self visibility)
CREATE POLICY ubr_select_self
ON public.user_business_role
FOR SELECT
USING (user_id = auth.uid());

-- INSERT / UPDATE / DELETE (admins & owners)
CREATE POLICY ubr_manage
ON public.user_business_role
FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_role me
    WHERE me.business_id = user_business_role.business_id
      AND me.user_id = auth.uid()
      AND me.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_role me
    WHERE me.business_id = user_business_role.business_id
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
    FROM public.user_business_role ubr
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
    FROM public.user_business_role ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin', 'member')
  )
);

-- UPDATE
CREATE POLICY reviews_update
ON public.reviews
FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_role ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_role ubr
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
    FROM public.user_business_role ubr
    WHERE ubr.business_id = reviews.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);


-- REVIEW_SOURCES TABLE --
ALTER TABLE public.review_source ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY review_source_select
ON public.review_source
FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_role ubr
    WHERE ubr.business_id = review_source.business_id
      AND ubr.user_id = auth.uid()
  )
);

-- INSERT / UPDATE / DELETE
CREATE POLICY review_source_manage
ON public.review_source
FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM public.user_business_role ubr
    WHERE ubr.business_id = review_source.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.user_business_role ubr
    WHERE ubr.business_id = review_source.business_id
      AND ubr.user_id = auth.uid()
      AND ubr.role IN ('owner', 'admin')
  )
);

-- USER_PROFILE TABLE --
ALTER TABLE public.user_profile ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY user_profile_select
ON public.user_profile
FOR SELECT
USING (id = auth.uid());

-- INSERT
CREATE POLICY user_profile_insert
ON public.user_profile
FOR INSERT
WITH CHECK (id = auth.uid());

-- UPDATE
CREATE POLICY user_profile_update
ON public.user_profile
FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
