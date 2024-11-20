CREATE MIGRATION m1sowouionreep5vdnm4m4slo4o3csygad4r4qmclyceohsg6o5wga
    ONTO m1k6we7m3uroymfaydtxyqfresxdzfbmbz3hkbe7le5qrmuphcycna
{
  ALTER TYPE design::Component {
      CREATE PROPERTY archivedAt: std::datetime;
  };
  ALTER TYPE design::DesignInstance {
      CREATE PROPERTY archivedAt: std::datetime;
  };
};
