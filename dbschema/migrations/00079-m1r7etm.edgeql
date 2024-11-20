CREATE MIGRATION m1r7etmdrorcqufixrsy6yabbiulsjfrbcip4ecoznzagcdfjasbgq
    ONTO m1bzmswuoz3gxphfhkdgnxe4zrdo4vbuiz5ogptnqoj4kxdy7joy2q
{
  ALTER TYPE default::Primitive {
      DROP ACCESS POLICY IAllowSuperAdminToSelectForAnalytics;
  };
};
