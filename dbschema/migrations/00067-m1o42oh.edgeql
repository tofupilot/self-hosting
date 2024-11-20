CREATE MIGRATION m1o42ohzfqfa7vzqgslnjve3vm75xv5w2op7e3ig7fo3oz5knodt5q
    ONTO m1lz4kq3fd4da6wqcapyo4r4hwa3a5zd7cjsw2anp3tjjtkqvprhcq
{
  ALTER TYPE default::Upload {
      DROP ACCESS POLICY org_members_have_full_access;
  };
  ALTER TYPE default::Upload {
      DROP ACCESS POLICY super_admin_can_read_for_analytics;
      EXTENDING default::PrimitiveProperty LAST;
      ALTER LINK organization {
          DROP OWNED;
          RESET TYPE;
      };
  };
  ALTER TYPE default::Upload {
      ALTER LINK createdBy {
          DROP OWNED;
          RESET TYPE;
      };
      ALTER PROPERTY createdAt {
          DROP OWNED;
          RESET TYPE;
      };
  };
};
