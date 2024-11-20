CREATE MIGRATION m14zrscppqv52swaodqbgapavznx737rpsz5poeq45hcdcghwj6xeq
    ONTO m1pvuuymyrhu5tu5l5dkmy3til2e3yvj3jj6bvpgsszqcru35ozsra
{
  ALTER TYPE analytics::Iteration {
      ALTER LINK designs {
          ON TARGET DELETE ALLOW;
      };
      ALTER LINK project {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
  ALTER TYPE analytics::Objective {
      ALTER LINK filterCategory {
          ON TARGET DELETE ALLOW;
      };
  };
};
