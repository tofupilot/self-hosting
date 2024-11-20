CREATE MIGRATION m17jj57ejxg7rewg6jpfkpssfeo22jgsa4z7nv4pafo673tctgv4fa
    ONTO m1xugxgnhvwnxyngpilgosvy6afi7tuww3mtli66ciexq44cr6crjq
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY super_admin;
  };
};
