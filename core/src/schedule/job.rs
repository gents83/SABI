use std::sync::{
    atomic::{AtomicUsize, Ordering},
    Arc,
};

pub struct Job {
    func: Box<dyn FnOnce() + Send + Sync>,
    wait_count: Option<Arc<AtomicUsize>>,
    name: String,
}

unsafe impl Sync for Job {}
unsafe impl Send for Job {}

impl Job {
    pub fn new<F>(name: String, func: F) -> Self
    where
        F: FnOnce() + Send + Sync + 'static,
    {
        Self {
            name,
            func: Box::new(func),
            wait_count: None,
        }
    }

    pub fn set_wait_count(&mut self, wait_count: Arc<AtomicUsize>) {
        self.wait_count = Some(wait_count);
    }
    pub fn get_name(&self) -> &str {
        self.name.as_str()
    }

    pub fn execute(mut self) {
        (self.func)();
        if let Some(wait_count) = self.wait_count {
            wait_count.fetch_sub(1, Ordering::SeqCst);
        }
        self.wait_count = None;
    }
}