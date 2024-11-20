CREATE MIGRATION m1utdkv2ly3vd64nfiogrcmwonh54hfu7kszi5ox7ruzsm77kar77q
    ONTO m16amejl5udswfop44zfichofeqifwigqcbjk4fu3h6sxbo3bdr4ea
{
  ALTER TYPE design::DesignInstance {
      ALTER LINK revision {
          RESET ON SOURCE DELETE;
      };
  };
  ALTER TYPE design::Revision {
      ALTER LINK component {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE design::DesignInstance {
      CREATE PROPERTY numberOfSiblings := ((std::count((SELECT
          .revision.component.revisions.designInstances
      )) - 1));
  };
};
