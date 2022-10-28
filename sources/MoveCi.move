
module 0x42::MoveCi {
    use std::signer;

    struct Counter has key { value: u64 }

    const ECOUNTER_EXISTS: u64 = 0;
    const ERESOURCE_DNE: u64 = 1;

    public entry fun publish_counter(account: &signer) {
        assert!(!exists<Counter>(signer::address_of(account)), ECOUNTER_EXISTS);
        move_to(account, Counter { value: 0 });
    }

    spec publish_counter {
        pragma aborts_if_is_strict;
        let addr = signer::address_of(account);
        aborts_if exists<Counter>(addr);

        let post count_post = global<Counter>(addr).value;
        ensures count_post == 0;
    }

    #[test(account = @0x111)]
    public entry fun publishes(account: signer) acquires Counter {
        publish_counter(&account);
        let addr = signer::address_of(&account);
        assert!(exists<Counter>(addr), ERESOURCE_DNE);
        assert!(borrow_global<Counter>(addr).value == 0, ECOUNTER_EXISTS);
    }

    public fun get_value(addr: address): u64 acquires Counter {
        borrow_global<Counter>(addr).value
    }

    public fun increment(account: &signer) acquires Counter {
        let addr = signer::address_of(account);
        assert!(exists<Counter>(addr), ERESOURCE_DNE);
        let value = get_value(addr);
        let value_ref = &mut borrow_global_mut<Counter>(addr).value;
        *value_ref = value + 1;
    }

    spec increment {
        let addr = signer::address_of(account);
        let count = global<Counter>(addr).value;

        aborts_if !exists<Counter>(addr) with ERESOURCE_DNE;
        aborts_if count + 1 > MAX_U64;

        let post count_post = global<Counter>(addr).value;
        ensures count_post == count + 1;
    }

    #[test(account = @0x111)]
    public fun increments(account: signer) acquires Counter {
        publish_counter(&account);
        increment(&account);

        let addr = signer::address_of(&account);
        assert!(exists<Counter>(addr), ERESOURCE_DNE);
        assert!(borrow_global<Counter>(addr).value == 1, 3);
    }

}
