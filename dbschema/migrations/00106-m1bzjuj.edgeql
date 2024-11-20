CREATE MIGRATION m1bzjuj45jfkudcq6tylt2zmbviyv2aggungzftb4qfl4syxxq7yka
    ONTO m14zrscppqv52swaodqbgapavznx737rpsz5poeq45hcdcghwj6xeq
{
  ALTER TYPE default::Category {
      ALTER LINK project {
          ON TARGET DELETE DELETE SOURCE;
      };
  };
};
