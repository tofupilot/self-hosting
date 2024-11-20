CREATE MIGRATION m1pvuuymyrhu5tu5l5dkmy3til2e3yvj3jj6bvpgsszqcru35ozsra
    ONTO m1ldpv3yjo5wmjvj64f7zh7hwhiem2nht2yeaxwcbnbx6asshk2q2q
{
  ALTER TYPE default::Project {
      ALTER PROPERTY externalName1 {
          DROP CONSTRAINT std::max_len_value(30);
      };
  };
  ALTER TYPE default::Project {
      ALTER PROPERTY externalName1 {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
  ALTER TYPE default::Project {
      ALTER PROPERTY externalName2 {
          DROP CONSTRAINT std::max_len_value(30);
      };
  };
  ALTER TYPE default::Project {
      ALTER PROPERTY externalName2 {
          CREATE CONSTRAINT std::max_len_value(50);
      };
  };
};
