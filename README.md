# Trainee-køen

Oppgavekø for traineene ved Krogsveen Kristiansand.

- `index.html` – selve siden
- `config.js` – kobling til Supabase (URL og anon-nøkkel)
- `supabase.sql` – oppsett av database, tilgangsregler og meglere
- `bilder/` – bilder av meglerne
- `CNAME` – domenet (trainee-kø.no skrives som xn--trainee-k-t8a.no)

## Innlogging
Siden spør bare om et passord. Det finnes to felles brukere i Supabase (Authentication → Users → Add user, huk av for auto-confirm):

- `kontor@trainee-ko.no` – passordet meglerne bruker. Kan bare legge inn oppgaver.
- `trainee@trainee-ko.no` – passordet til Victor og Siw. Gir trainee-siden.

Passordene sjekkes uten forskjell på store og små bokstaver, så de må lagres med små bokstaver i Supabase.

Gi trainee-brukeren rollen sin:

    insert into public.roles (user_id, role, name)
    select id, 'trainee', 'Trainee' from auth.users where email = 'trainee@trainee-ko.no';

Slå av "Allow new users to sign up" under Authentication → Sign In / Providers.
