CREATE MIGRATION m1auehtulrbidqr63rtjgvyw3llo42bqlkynssn6ulvlah6iaolmxa
    ONTO m1ob5enzfo6jyo6sqbwwxv6c4mwlyzgefdqspckjbddh47niifyxja
{
  ALTER TYPE activity::LabelChange {
      CREATE PROPERTY type := ((std::str_split(.__type__.name, '::'))[1]);
  };
  ALTER TYPE activity::OwnerChange {
      CREATE PROPERTY type := ((std::str_split(.__type__.name, '::'))[1]);
  };
  ALTER TYPE activity::StatusChange {
      CREATE PROPERTY type := ((std::str_split(.__type__.name, '::'))[1]);
  };
};
