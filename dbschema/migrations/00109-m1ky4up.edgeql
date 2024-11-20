CREATE MIGRATION m1ky4upeyumkooxu7iyxt2olkgqttd2uqxjvxk6nusudb7jhaey6aa
    ONTO m1utdkv2ly3vd64nfiogrcmwonh54hfu7kszi5ox7ruzsm77kar77q
{
  ALTER TYPE design::DesignInstance {
      CREATE PROPERTY numberOfDisplayedSiblings := ((std::count((SELECT
          .revision.component.revisions.designInstances
      FILTER
          (NOT (EXISTS (.parents)) OR EXISTS (.parents.designInstances))
      )) - 1));
  };
};
