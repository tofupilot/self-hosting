CREATE MIGRATION m1lz4kq3fd4da6wqcapyo4r4hwa3a5zd7cjsw2anp3tjjtkqvprhcq
    ONTO m1bitw5p6rta3vnh36bogzxjmxute556hxcbaxnumwyd2inti3apia
{
  ALTER TYPE default::Label {
      DROP ACCESS POLICY org_members_have_full_access;
      DROP ACCESS POLICY super_admin_can_read_for_analytics;
  };
  ALTER TYPE default::Project {
      DROP ACCESS POLICY org_members_have_full_access;
      DROP ACCESS POLICY super_admin_can_read_for_analytics;
  };
  ALTER TYPE default::Status {
      DROP ACCESS POLICY org_members_have_full_access;
      DROP ACCESS POLICY super_admin_can_read_for_analytics;
  };
};
