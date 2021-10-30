# pastemyst v3

make sure to run `git submodule update --init --recursive` when you first clone this repo.

## process for updating grammars

```sh
# delete the current grammars dir
rm -r frontend/grammars

# pull a newer version of the linguist submodule, and stage it
git submodule foreach git pull
git add linguist

# bootstrap linguist
./linguist/script/bootstrap

# compile grammars
./linguist/script/build-grammars-tarball

# move the built grammars
mv linguist/linguist-grammars frontend/grammars

# copy the languages.yml
cp linguist/lib/linguist/languages.yml backend/Data/languages.yml
```